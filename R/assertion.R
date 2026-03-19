#' Assert level
#'
#' @param x `picks` object
#' @param class Class of the last element of picks
#' @inheritParams checkmate::makeAssertionFunction
#' @inheritParams checkmate::assert
#' @rdname assert_last_level
#' @returns For `check_last_level` a logical value or a string.
#' For `assert_last_level` invisibly the object checked or an error.
#' @export
#' @examples
#' x <- picks(datasets(), variables(), values())
#' assert_last_level(x, "values")
check_last_level <- function(x, class) {
  checkmate::assert_character(class, len = 1, any.missing = FALSE)
  check <- inherits(x, "picks") && inherits(x[[length(x)]], class)
  if (isFALSE(check)) {
    return(sprintf("This is not a picks object that ends in %s", class))
  }
  check
}

#' @export
#' @rdname assert_last_level
assert_last_level <- checkmate::makeAssertionFunction(check_last_level)
