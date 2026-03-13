
#' Assert level
#'
#' @param x `picks` object
#' @param class Class of the last element of picks
#' @rdname assert_level
#' @returns For `check_level` a logical value or a string.
#' For `assert_level` invisibly the object checked or an error.
#' @export
#'
#' @examples
#' x <- picks(datasets(), variables(), values())
#' assert_level(x, "values")
check_level <- function(x, class) {
  assertthat::is.string(class)
  check <- inherits(x, "picks") && inherits(x[[length(x)]], class)
  if (isFALSE(check)) {
    return(sprintf("This is not a picks object that ends in %s", class))
  }
  check
}

#' @export
#' @rdname assert_level
assert_level <- checkmate::makeAssertionFunction(check_level)