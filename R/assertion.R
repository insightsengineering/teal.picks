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
#' @param datasets (`logical(1)`) whether to check for the presence of a `datasets` element.
#' @param variables (`logical(1)`) whether to check for the presence of a `variables` element
#' @param values (`logical(1)`) whether to check for the presence of a `values` element
#' @inheritParams checkmate::makeAssertionFunction
#' @inheritParams checkmate::assert
#' @rdname assert_picks
#' @returns For `check_picks` a logical value or a string.
#' For `assert_picks` invisibly the object checked or an error.
#' @examples
#' p <- picks(datasets(), variables(), values())
#' assert_picks(p, datasets = TRUE)
#' assert_picks(p, variables = TRUE)
#' assert_picks(p, values = TRUE)
#'
#' p <- picks(datasets(), variables())
#' check_picks(p, values = TRUE)
#' @export
check_picks <- function(x, datasets = TRUE, variables = FALSE, values = FALSE) {
  checkmate::assert_flag(datasets)
  checkmate::assert_flag(variables)
  checkmate::assert_flag(values)

  if (!inherits(x, "picks")) {
    return(sprintf("Must be a 'picks' object, not '%s'", class(x)[1]))
  }

  if (
    (datasets || variables || values) &&
      (length(x) < 1 || !inherits(x[[1]], "datasets"))
  ) {
    return("Must have datasets() as the first element")
  }

  if ((variables || values) && (length(x) < 2 || !inherits(x[[2]], "variables"))) {
    return("Must have variables() as the second element")
  }

  if (values && (length(x) < 3 || !inherits(x[[3]], "values"))) {
    return("Must have values() as the third element")
  }

  if (length(x) > 3) {
    return("Cannot contain more than 3 elements")
  }

  if (any(!names(x) %in% c("datasets", "variables", "values"))) {
    return("Has invalid names in object, can only contain 'datasets', 'variables', and 'values'")
  }

  # Check if values exists and is preceded by variables
  element_classes <- vapply(x, FUN = methods::is, FUN.VALUE = character(1))
  values_idx <- which(element_classes == "values")

  if (length(values_idx) > 0) {
    variables_idx <- which(element_classes == "variables")
    if (length(variables_idx) == 0) {
      return("picks() requires variables() before values()")
    }
    if (values_idx != variables_idx + 1) {
      return("values() must immediately follow variables() in picks()")
    }
  }

  TRUE
}

#' @export
#' @rdname assert_picks
assert_picks <- checkmate::makeAssertionFunction(check_picks)
