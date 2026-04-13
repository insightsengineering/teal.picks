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
#' @examples
#' p <- picks(
#'   datasets(is.data.frame, 2L),
#'   variables(is_categorical(2, 10))
#' )
#' resolver(data = list(mtcars = mtcars, iris = iris), x = p)
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
#' Helper to work with ranges. Setting `choices` or `selected` to range using
#' `ranged()` in any of them will automatically create a `numeric`, `Date` or `POSIXct`
#' input to filter. `variables(choices)` must only refer to `numeric`, `Date`, or `POSIXct`
#' columns. An informative error is raised if the resolved column type is unsupported.
#' @param min (`numeric(1)`) Minimal value.
#' @param max (`numeric(1)`) Maximal value.
#' @export
#' @examples
#' p <- picks(
#'   datasets(choices = "mtcars"),
#'   variables(choices = is.numeric, selected = 1),
#'   values(choices = ranged(), ranged(20, 30))
#' )
#' resolver(data = list("mtcars label" = mtcars), x = p)
ranged <- function(min = -Inf, max = Inf) {
  checkmate::assert_number(min)
  checkmate::assert_number(max)
  if (min > max) {
    stop("`min` must be lower than `max`")
  }
  .as_ranged(
    function(x) {
      !is.na(x) & x <= max & x >= min
    }
  )
}

#' Check if choices/selected is a range.
#'
#' @noRd
.is_ranged <- function(x) {
  inherits(x, "ranged")
}

#' Set "ranged" class to the object. Be watchful as
#' it is used in two contexts.
#' 1. Unresolved range in `values`'s `choices` and `selected` - setting a range predicate to
#' be resolved in `determine`
#' 2. Resolved range - sets a class to the `choices` and `selected` to inform that resolved vector
#' is a range, to show a `numericRangeInput` and to filter values by `lower >= x <= upper`
#'
#' @noRd
.as_ranged <- function(x) {
  class(x) <- c(class(x), "ranged")
  x
}
