#' Resolve `picks`
#'
#' Resolve iterates through each `picks` element and determines values .
#' @param x ([picks()]) settings for picks.
#' @param data ([teal_data()] `environment` or `list`) any data collection supporting object extraction with `[[`.
#' Used to determine values of unresolved `picks`.
#'
#' @returns resolved `picks`.
#' @export
#'
#' @examples
#' x <- picks(datasets(tidyselect::where(is.data.frame)), variables("a", "a"))
#' data <- list(
#'   df1 = data.frame(a = as.factor(LETTERS[1:5]), b = letters[1:5]),
#'   df2 = data.frame(a = LETTERS[1:5], b = 1:5),
#'   m = matrix()
#' )
#' resolver(x = x, data = data)
resolver <- function(x, data) {
  checkmate::assert_class(x, "picks")
  checkmate::assert(
    is.environment(data),
    checkmate::check_list(data, names = "unique")
  )
  data_i <- data
  for (i in seq_along(x)) {
    determined_i <- determine(x[[i]], data = data_i)
    data_i <- determined_i$data
    x[[i]] <- determined_i$x
  }
  x
}

#' A method that should take a type and resolve it.
#'
#' Generic that makes the minimal check on spec.
#' Responsible of subsetting/extract the data received and check that the type matches
#' @param x The specification to resolve.
#' @param data The minimal data required.
#' @return A list with two elements, the `type` resolved and the data extracted.
#' @keywords internal
determine <- function(x, data) {
  if (is.null(data)) { # this happens when <previous>$selected=NULL
    return(list(x = .nullify_pick(x)))
  }
  UseMethod("determine")
}

#' @export
determine.datasets <- function(x, data) {
  checkmate::assert(is.environment(data), is.list(data))
  data <- as.list(data)
  x$choices <- .determine_choices(x = x$choices, data = data)
  x$selected <- .determine_selected(
    x = x$selected,
    data = data[intersect(x$choices, names(data))],
    multiple = attr(x, "multiple")
  )
  list(x = x, data = .extract(x, data))
}

#' @export
determine.variables <- function(x, data) {
  checkmate::assert_multi_class(data, c("data.frame", "tbl_df", "data.table", "DataFrame"))
  if (ncol(data) <= 0L) {
    warning("Selected dataset has no columns", call. = FALSE)
    return(list(x = .nullify_pick(x)))
  }

  x$choices <- .determine_choices(x$choices, data = data)
  x$selected <- .determine_selected(
    x$selected,
    data = data[intersect(x$choices, colnames(data))],
    multiple = attr(x, "multiple")
  )
  list(x = x, data = .extract(x, data))
}

#' @export
determine.values <- function(x, data) {
  data <- if (ncol(data) > 1) {
    apply(data, 1, toString)
  } else {
    data[[1]]
  }

  x$choices <- .determine_choices(x$choices, data = data) # .determine_* uses names
  x$selected <- if (length(x$choices)) {
    .determine_selected(x$selected, data = stats::setNames(x$choices, x$choices), multiple = attr(x, "multiple"))
  }
  list(x = x) # no picks element possible after picks(..., values) (no need to pass data further)
}


#' Evaluate delayed choices
#'
#' @param data (`list`, `data.frame`, `vector`)
#' @param x (`character`, `quosure`, `function(x)`) to determine `data` elements to extract.
#' @param multiple (`logical(1)`) whether multiple selection is possible.
#'
#' @details
#'
#' ## Various ways to evaluate choices/selected.
#'
#' Function resolves `x` to determine `choices` or `selected`. `x` is matched in multiple ways with
#' `data` to return valid choices:
#' - `x (character)`: values are matched with names of data and only intersection is returned.
#' - `x (tidyselect-helper)`: using [tidyselect::eval_select]
#' - `x (function)`: function is executed on each element of `data` to determine where function returns TRUE
#'
#' Mechanism is robust in a sense that it never fails (`tryCatch`) and returns `NULL` if no-match found. `NULL`
#' in [determine()] is handled gracefully, by setting `NULL` to all following components of `picks`.
#'
#' In the examples below you can replace `.determine_delayed` with `.determine_choices` or `.determine_selected`.
#'
#' - `character`: refers to the object name in `data`, for example
#'    ```
#'    .determine_delayed(data = iris, x = "Species")
#'    .determine_delayed(data = iris, x = c("Species", "inexisting"))
#'    .determine_delayed(data = list2env(list(iris = iris, mtcars = mtcars)), x = "iris")
#'    ```
#' - `quosure`: delayed (quoted) `tidyselect-helper` to be evaluated through `tidyselect::eval_select`. For example
#'   ```
#'   .determine_delayed(data = iris, x = rlang::quo(tidyselect::starts_with("Sepal")))
#'   .determine_delayed(data = iris, x = rlang::quo(1:2))
#'   .determine_delayed(data = iris, x = rlang::quo(Petal.Length:Sepal.Length))
#'   ```
#' - `function(x)`: predicate function returning a logical flag. Evaluated for each `data` element. For example
#'   ```
#'
#'   .determine_delayed(data = iris, x = is.numeric)
#'   .determine_delayed(data = letters, x = function(x) x > "c")
#'   .determine_delayed(data = list2env(list(iris = iris, mtcars = mtcars, a = "a")), x = is.data.frame)
#'   ```
#'
#' @return `character` containing names/levels of `data` elements which match `x`, with two differences:
#' - `.determine_choices` returns vector named after data labels
#' - `.determine_selected` cuts vector to scalar when `multiple = FALSE`
#'
#' @keywords internal
.determine_choices <- function(x, data) {
  out <- .determine_delayed(data = data, x = x)
  if (!is.null(names(data)) && !is.atomic(data) && is.character(out) && is.null(names(out))) {
    # only named non-atomic can have label
    # don't rename if names provided by app dev
    labels <- vapply(
      out,
      FUN = function(choice) c(attr(data[[choice]], "label"), choice)[1],
      FUN.VALUE = character(1)
    )
    stats::setNames(out, labels)
  } else {
    out
  }
}

#' @rdname dot-determine_choices
.determine_selected <- function(x, data, multiple = FALSE) {
  if (!is.null(x) && length(data)) {
    out <- .determine_delayed(data = data, x = x)
    if (!isTRUE(multiple) && length(out) > 1) {
      warning(
        "`multiple` has been set to `FALSE`, while selected contains multiple values, forcing to select first:",
        rlang::as_label(x)
      )
      out <- out[1]
    }
    out
  }
}

#' @rdname dot-determine_choices
.determine_delayed <- function(x, data) {
  if (length(dim(data)) == 2L) { # for example matrix
    data <- as.data.frame(data)
  }

  out <- tryCatch( # app developer might provide failing function
    if (inherits(data, c("integer", "numeric", "Date", "POSIXct"))) {
      data_range <- range(data, na.rm = TRUE)
      this_range <- if (inherits(x, c("integer", "numeric", "Date", "POSIXct")) && length(x) == 2) {
        x
      } else if (is.function(x)) {
        idx_match <- unique(which(vapply(data, x, logical(1))))
        range(data[idx_match], na.rm = TRUE)
      } else {
        data_range
      }
      mins <- c(this_range[1], data_range[1])
      maxs <- c(this_range[2], data_range[2])
      mins <- mins[is.finite(mins)]
      maxs <- maxs[is.finite(maxs)]
      if (length(mins) && length(maxs)) {
        c(max(mins), min(maxs))
      }
    } else {
      if (is.character(x) && length(x)) {
        # don't need to evaluated eager choices - just make sure choices are subset of possible
        x[which(x %in% .possible_choices(data))]
      } else if (is.function(x)) {
        if (inherits(x, "des-delayed")) {
          x(data)
        } else {
          idx_match <- unique(which(vapply(data, x, logical(1))))
          .possible_choices(data[idx_match])
        }
      } else if (rlang::is_quosure(x)) {
        # app developer might provide failing function
        idx_match <- unique(tidyselect::eval_select(expr = x, data))
        .possible_choices(data[idx_match])
      }
    },
    error = function(e) NULL # not returning error to avoid design complication to handle errors
  )

  if (length(out) == 0) {
    warning(
      "None of the `choices/selected`: ", rlang::as_label(x), "\n",
      "are subset of: ", toString(.possible_choices(data), width = 30), "\n",
      "Emptying choices..."
    )
    return(NULL)
  }
  # unique() for idx containing duplicated values
  if (is.atomic(out) && length(out)) out # this function should return atomic vector of length > 1 or NULL
}

#' @rdname dot-determine_choices
.possible_choices <- function(data) {
  if (is.factor(data)) {
    levels(data)
  } else if (inherits(data, c("numeric", "Date", "POSIXct"))) {
    suppressWarnings(range(data, na.rm = TRUE)) # we don't need to warn as we handle this case (inf)
  } else if (is.character(data)) {
    unique(data)
  } else {
    names(data)
  }
}

.extract <- function(x, data) {
  if (length(x$selected) == 0) {
    NULL # this nullifies following pick-elements. See determine (generic)
  } else if (length(x$selected) == 1 && inherits(x, "datasets")) {
    data[[x$selected]]
  } else if (all(x$selected %in% names(data))) {
    data[x$selected]
  }
}

.nullify_pick <- function(x) {
  x$choices <- NULL
  x$selected <- NULL
  x
}
