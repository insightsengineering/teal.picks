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
determine.default <- function(x, data) {
  stop("Object class not recognized to resolve inside teal.picks")
}


#' @export
determine.pick <- function(x, data) {
  x$choices <- .determine_choices(x = x$choices, data = data)
  x$selected <- .determine_selected(
    x = x$selected,
    data = data[intersect(x$choices, names(data))],
    multiple = attr(x, "multiple")
  )
  list(x = x, data = .extract(x, data))
}
#' @export
determine.datasets <- function(x, data) {
  checkmate::assert(is.environment(data), is.list(data))
  data <- as.list(data)
  NextMethod("determine", x)
}

#' @export
determine.variables <- function(x, data) {
  checkmate::assert_multi_class(data, c("data.frame", "tbl_df", "data.table", "DataFrame"))
  if (ncol(data) <= 0L) {
    warning("Selected dataset has no columns", call. = FALSE)
    return(list(x = .nullify_pick(x)))
  }
  NextMethod("determine", x)
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
#'
#' * `.possible_choices()`: Based on the data object provides choices to be selected from.
#' * `.determine_choices()`, `.determine_selected()`: resolve the choices and selected.
#' * `.determine_delayed()` helper to resolve delayed choices or selections (depending on the `data`).
#'
#' @param data (`list`, `data.frame`, `vector`) Data available to determine resolution.
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
#'    .determine_delayed(data = list(iris = iris, mtcars = mtcars), x = "iris")
#'    ```
#' - `quosure`: delayed (quoted) `tidyselect-helper` to be evaluated through `tidyselect::eval_select`. For example
#'   ```
#'   .determine_delayed(data = iris, x = tidyselect::starts_with("Sepal"))
#'   .determine_delayed(data = iris, x = 1:2)
#'   .determine_delayed(data = iris, x = Petal.Length:Sepal.Length)
#'   ```
#' - `function(x)`: predicate function returning a logical flag. Evaluated for each `data` element. For example
#'   ```
#'
#'   .determine_delayed(data = iris, x = is.numeric)
#'   .determine_delayed(data = letters, x = function(x) x > "c")
#'   .determine_delayed(data = list(iris = iris, mtcars = mtcars, a = "a"), x = where(is.data.frame))
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

# This function should return atomic vector of length >= 1 or NULL
#' @rdname dot-determine_choices
.determine_delayed <- function(x, data) {
  orig_data <- data
  data <- .possible_choices(orig_data)

  if (rlang::is_quosure(x)) {
    y <- x
  } else {
    y <- rlang::enquo(x)
  }
  # To only expose public functions
  caller_env <- rlang::caller_env(n = 2)

  # Order of data
  # 1. Original data provided
  # 2. Names of data
  pos <- tryCatch(
    tidyselect::eval_select(
      expr = y,
      data = orig_data,
      allow_rename = TRUE,
      error_call = caller_env
    ),
    error = function(e) {
      tidyselect::eval_select(y,
        data,
        allow_rename = TRUE,
        error_call = caller_env
      )
    },
    finally = function(ff) {
      if (rlang::is_condition(ff)) {
        rlang::abort(ff, call = rlang::caller_env(n = 3))
      }
    }
  )

  out <- data[pos]
  # Rename with the picks names
  if (!is.null(names(x))) {
    out <- x[pos]
  }

  if (length(out) == 0) {
    warning(
      "None of the `choices/selected`: ", rlang::as_label(x), "\n",
      "are subset of: ", toString(datas, width = 30), "\n",
      "Emptying choices..."
    )
    return(NULL)
  }
  if (is.atomic(out) && length(out)) out else NULL
}

#' Return when appropriate labels or names
#'
#' Precedence:
#' 1. Picks labels
#' 2. Labels data
#' 3. Name data
#' 4. Vector
#' @param data The possible `data` for resolution.
#' @rdname dot-determine_choices
.possible_choices <- function(data) {
  new_data <- if (is.factor(data)) {
    levels(data)
  } else if (inherits(data, c("character", "numeric"))) {
    unique(data)
  } else if (is.list(data) && !is.null(names(data))) {
    names(data)
  } else if (is.list(data) && is.null(names(data))) {
    seq_along(data)
  } else {
    unique(data)
  }

  if (is.list(data)) {
    labels <- lapply(data, attr, which = "label")
    labels <- unlist(labels, recursive = FALSE, use.names = FALSE)
  } else {
    labels <- attr(data, "label")
  }

  new_name <- if (!is.null(labels)) {
    labels
  } else if (is.vector(new_data)) {
    new_data
  } else {
    stop("Selection or choices is not in the right format", call. = FALSE)
  }
  if (length(new_name) != length(new_data)) {
    new_name <- seq_along(new_data)
  }

  names(new_data) <- new_name
  new_data
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
