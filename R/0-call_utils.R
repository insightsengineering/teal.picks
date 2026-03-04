#' Checks `varname` argument and convert to call
#'
#' Checks `varname` type and parse if it's a `character`.
#'
#' @param varname (`name` or `call` or `character(1)`)
#' name of the variable
#'
#' @returns the parsed `varname`.
#'
#' @keywords internal
#'
call_check_parse_varname <- function(varname) {
  checkmate::assert(
    checkmate::check_string(varname),
    checkmate::check_class(varname, "call"),
    checkmate::check_class(varname, "name")
  )
  if (is.character(varname)) {
    parsed <- parse(text = varname, keep.source = FALSE)
    if (length(parsed) == 1) {
      varname <- parsed[[1]]
    } else {
      stop(
        sprintf(
          "Problem with parsing '%s'. Not able to process multiple calls",
          varname
        )
      )
    }
  }
  varname
}

#' Choices condition call
#'
#' Compose choices condition call from inputs.
#'
#' @details
#' `choices` can be vector of any type but for some output might be converted:
#' * `factor` call is composed on choices converted to `character`;
#' * `Date` call is composed on choices converted to `character` using
#' `format(choices)`;
#' * `POSIXct`, `POSIXlt` call is composed on choices converted to `character` using
#' `format(choices)`.
#'
#' One has to be careful here as formatted date-time variable might loose
#' some precision (see `format` argument in [format.POSIXlt()] and output call
#' could be insufficient for exact comparison. In this case one should specify
#' `varname = trunc(<varname>)` and possibly convert `choices` to `character`).
#'
#' @param varname (`name` or `call` or `character(1)`)
#' name of the variable.
#' @param choices (`vector`)
#' `varname` values to match using the `==` (single value) or `%in%` (vector)
#' condition.
#'
#' @return `call`.
#'
#' @keywords internal
#'
call_condition_choice <- function(varname, choices) {
  varname <- call_check_parse_varname(varname)

  if (is.factor(choices)) {
    choices <- as.character(choices)
  } else if (inherits(choices, "Date")) {
    choices <- format(choices)
  } else if (inherits(choices, c("POSIXct", "POSIXlt"))) {
    choices <- format(choices)
  }


  if (length(choices) == 1) {
    call("==", varname, unname(choices))
  } else {
    c_call <- do.call(
      "call",
      append(list("c"), unname(choices))
    )
    # c_call needed because it needs to be vector call
    # instead of vector. SummarizedExperiment.subset
    # handles only vector calls
    call("%in%", varname, c_call)
  }
}

#' `numeric` range condition call
#'
#' Compose `numeric` range condition call from inputs.
#'
#' @param varname (`name` or `character(1)`)
#' name of the variable.
#'
#' @param range (`numeric(2)`)
#' range of the variable.
#'
#' @return `call`.
#'
#' @keywords internal
#'
call_condition_range <- function(varname, range) {
  checkmate::assert_numeric(range, len = 2, sorted = TRUE)

  varname <- call_check_parse_varname(varname)
  call(
    "&",
    call(">=", varname, unname(range[1])),
    call("<=", varname, unname(range[2]))
  )
}

#' `logical` variable condition call
#'
#' Compose `logical` variable condition call from inputs.
#'
#' @param varname (`name` or `character(1)`)
#' name of the variable
#'
#' @param choice (`logical(1)`)
#' chosen value
#'
#' @return `call`.
#'
#' @keywords internal
#'
call_condition_logical <- function(varname, choice) {
  checkmate::assert_flag(choice)
  varname <- call_check_parse_varname(varname)

  if (choice) {
    varname
  } else if (!choice) {
    call("!", varname)
  } else {
    stop(
      "Unknown filter state", toString(choice),
      " for logical var ", as.character(varname)
    )
  }
}

#' `POSIXct` range condition call
#'
#' Compose `POSIXct` range condition call from inputs.
#'
#' @param varname (`name` or `character(1)`) name of the variable.
#' @param range (`POSIXct`) range of the variable.
#' Be aware that output uses truncated range format `"%Y-%m-%d %H:%M:%S"`,
#' which means that some precision might be lost.
#' @param timezone (`character(1)`) specifies the time zone to be used for the conversion.
#' By default `Sys.timezone()` is used.
#'
#' @return `call`.
#'
#' @keywords internal
#'
call_condition_range_posixct <- function(varname, range, timezone = Sys.timezone()) {
  checkmate::assert_posixct(range, len = 2, sorted = TRUE)
  checkmate::assert_string(timezone)
  varname <- call_check_parse_varname(varname)

  range[1] <- trunc(range[1], units = c("secs"))
  range[2] <- trunc(range[2] + 1, units = c("secs"))

  range <- format.POSIXct(
    unname(range),
    format = "%Y-%m-%d %H:%M:%S",
    tz = timezone
  )

  call(
    "&",
    call(">=", varname, call("as.POSIXct", range[1], tz = timezone)),
    call("<", varname, call("as.POSIXct", range[2], tz = timezone))
  )
}

#' `Date` range condition call
#'
#' Compose `Date` range condition call from inputs.
#'
#' @param varname (`name` or `character(1)`) name of the variable.
#' @param range (`Date`) range of the variable.
#'
#' @return `call`.
#'
#' @keywords internal
#'
call_condition_range_date <- function(varname, range) {
  checkmate::assert_date(range, len = 2)
  checkmate::assert_true(range[2] >= range[1])
  varname <- call_check_parse_varname(varname)

  call(
    "&",
    call(">=", varname, call("as.Date", as.character(range[1]))),
    call("<=", varname, call("as.Date", as.character(range[2])))
  )
}

#' Combine calls by operator
#'
#' Combine list of calls by specific operator.
#'
#' @param operator (`character(1)` or `name`) name / symbol of the operator.
#' @param calls (`list` of calls) list containing calls to be combined by `operator`.
#'
#' @return A combined `call`.
#'
#' @keywords internal
#'
calls_combine_by <- function(operator, calls) {
  checkmate::assert_string(operator)
  stopifnot(
    all(
      vapply(
        X = calls,
        FUN.VALUE = logical(1),
        FUN = function(x) is.language(x) || is.logical(x)
      )
    )
  )
  Reduce(
    x = calls,
    f = function(x, y) call(operator, x, y)
  )
}

#' @param variables (`list` of `character`) variables to select. If list is named then
#'  variables will be renamed if their name is different than its value
#'  (this produces a call `select(..., <name> = <value>)`).
.call_dplyr_select <- function(dataname, variables) {
  as.call(
    c(
      list(
        str2lang("dplyr::select"),
        str2lang(dataname)
      ),
      lapply(unname(variables), as.name)
    )
  )
}

.call_dplyr_filter <- function(x) {
  predicates <- lapply(unname(x), function(x) {
    if (is.numeric(x$values)) {
      call_condition_range(varname = x$variables, range = x$values)
    } else if (inherits(x$values, "Date")) {
      call_condition_range_date(varname = x$variables, range = x$values)
    } else if (inherits(x$values, "POSIXct")) {
      call_condition_range_posixct(varname = x$variables, range = x$values)
    } else if (is.logical(x$values)) {
      call_condition_logical(varname = x$variables, choice = x$values)
    } else if (length(x$variables)) {
      variable <- if (length(x$variables) > 1) {
        as.call(
          c(
            list(
              quote(paste)
            ),
            unname(lapply(x$variables, as.name)),
            list(sep = ", ")
          )
        )
      } else {
        x$variables
      }
      call_condition_choice(varname = variable, choices = x$values)
    }
  })
  as.call(
    c(
      list(str2lang("dplyr::filter")),
      Filter(length, predicates)
    )
  )
}
