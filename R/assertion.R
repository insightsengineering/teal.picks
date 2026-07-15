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

#' Assert picks contains a specific element
#'
#' Check whether a `picks` object contains at least one element of the given
#' class (`"datasets"`, `"variables"`, or `"values"`).
#'
#' @param x `picks` object
#' @param element (`character(1)`) one of `"datasets"`, `"variables"`, or
#'   `"values"`.
#' @inheritParams checkmate::makeAssertionFunction
#' @inheritParams checkmate::assert
#' @rdname assert_picks_has
#' @returns For `check_picks_has` a logical value or a string.
#' For `assert_picks_has` invisibly the object checked or an error.
#' @export
#' @examples
#' p <- picks(datasets(), variables(), values())
#' assert_picks_has(p, "datasets")
#' assert_picks_has(p, "variables")
#' assert_picks_has(p, "values")
check_picks_has <- function(x, element = c("datasets", "variables", "values")) {
  element <- match.arg(element)
  if (!inherits(x, "picks")) {
    return("Must be a 'picks' object")
  }
  if (!any(vapply(x, inherits, logical(1), what = element))) {
    return(sprintf("Picks object does not contain a '%s' element", element))
  }
  TRUE
}

#' @export
#' @rdname assert_picks_has
assert_picks_has <- checkmate::makeAssertionFunction(check_picks_has)
