#' `tidyselect` helpers
#'
#' @description
#' #' `r lifecycle::badge("experimental")`
#' Predicate functions simplifying `picks` specification.
#' @examples
#' # select factor column but exclude foreign keys
#' variables(choices = is_categorical(min.len = 2, max.len = 10))
#'
#' @name tidyselectors
#' @rdname tidyselectors
#' @param min.len (`integer(1)`) minimal number of unique values
#' @param max.len (`integer(1)`) maximal number of unique values
#' @export
is_categorical <- function(min.len, max.len) {
  # todo: consider making a function which can exit earlier when max.len > length(unique(x)) < min.len
  #       without a need to compute unique on the whole vector.
  if (missing(max.len) && missing(min.len)) {
    function(x) is.factor(x) || is.character(x)
  } else if (!missing(max.len) && missing(min.len)) {
    checkmate::assert_int(max.len, lower = 0)
    function(x) (is.factor(x) || is.character(x)) && length(unique(x)) <= max.len
  } else if (!missing(min.len) && missing(max.len)) {
    checkmate::assert_int(min.len, lower = 0)
    function(x) (is.factor(x) || is.character(x)) && length(unique(x)) >= min.len
  } else {
    checkmate::assert_int(min.len, lower = 0)
    checkmate::assert_int(max.len, lower = 0)
    checkmate::assert_true(max.len >= min.len)
    function(x) {
      (is.factor(x) || is.character(x)) && {
        n <- length(unique(x))
        n >= min.len && n <= max.len
      }
    }
  }
}

#' Select a range
#'
#' Helper functions for working with ranges. Main function is `ranged`.
#' @param x Some data
#' @param min Minimal value.
#' @param max Maximal value.
#' @export
#' @examples
#' p <- picks(
#'   datasets("mtcars", "mtcars"),
#'   variables(is.numeric, "disp"),
#'   values(ranged(110, Inf), ranged(110, 300))
#' )
#' could_be_range(mtcars$disp)
#' could_be_range(iris$Species)
#' is_range(p$values$selected)
#' r <- resolver(data = list(mtcars = mtcars), x = p)
#' is_range(r$values$selected)
ranged <- function(min, max) {
  if (is.na(max)) {
    max <- Inf
  }
  if (is.na(min)) {
    min <- -Inf
  }
  stopifnot(identical(is(min), is(max)))
  predicate <- rlang::as_function(~ .x <= max & .x >= min)
  call <- rlang::current_call()
  fn <- function(x, ...) {
    stopifnot(identical(is(min), is(x)))
    if (!could_be_range(x)) {
      stop("Can't be a range.")
    }
    out <- predicate(x, ...)
    if (!rlang::is_bool(out)) {
      abort("Tidyselect like function", call = call)
    }
    out
  }
  class(fn) <- c("range", class(fn))
  fn
}

#' @export
#' @describeIn ranged Check if it is a range.
is_range <- function(x) {
  inherits(x, "range")
}

#' @export
#' @describeIn ranged Check if some values could be a ranged output.
could_be_range <- function(x) {
  inherits(x, c("Date", "numeric", "POSIXt")) || (is.factor(x) && inherits(x, "ordered"))
}

#' Return when appropriate labels or names
#'
#' Precedence:
#' 1. Picks labels
#' 2. Labels data
#' 3. Name data
#' 4. Numerical vector
#' @param data The possible `data` for resolution.
#' @noRd
name_data <- function(data) {
  if (length(dim(data)) == 2L) { # for example matrix
    .name(data)
  } else if (is.vector(data) && is.null(names(data))) {
    seq_along(data)
  } else if (is.list(data) && !is.null(names(data))) {
    .name(data)
  } else if (is.list(data) && is.null(names(data))) {
    seq_along(data)
  } else {
    .name(data)
  }
}

#' Retrieve labels or names of data
.name <- function(data) {
  if (is.list(data)) {
    labels <- lapply(data, attr, which = "label")
    labels <- unlist(labels, recursive = FALSE, use.names = FALSE)
  } else {
    labels <- attr(data, "label")
  }

  if (!is.null(labels)) {
    labels
  } else if (!is.null(names(data))) {
    names(data)
  } else {
    seq_along(data)
  }
}
