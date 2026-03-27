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
#' Helper functions for working with ranges. Main function is `ranged`.
#' @param min Minimal value.
#' @param max Maximal value.
#' @export
#' @examples
#' p <- picks(
#'   datasets(is.data.frame, is.data.frame),
#'   variables(is.numeric, 1),
#'   values(tidyselect::where(~ .x > 5), ranged(20, NA))
#' )
#' resolver(data = list("mtcars label" = mtcars), x = p)
ranged <- function(min, max) {
  if (is.na(max)) max <- Inf
  if (is.na(min)) min <- -Inf

  predicate <- rlang::as_function(~ !is.na(.x) & .x <= max & .x >= min)
  call <- rlang::current_call()
  fn <- function(x, ...) {
    out <- predicate(x, ...)
    out
  }
  class(fn) <- c("range", class(fn))
  fn
}

#' Check if choices/selected is a range.
#' @noRd
.is_range <- function(x) {
  inherits(x, "range")
}
