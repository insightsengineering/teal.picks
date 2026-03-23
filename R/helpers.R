update_fixed_picks <- function(x, value) {
  checkmate::assert_class(x, "picks")
  checkmate::assert_logical(value, len = 1, any.missing = FALSE)
  attr(x, "fixed") <- value
  x
}

fix_picks <- function(x) {
  update_fixed_picks(x, TRUE)
}

unfix_picks <- function(x) {
  update_fixed_picks(x, FALSE)
}


#' Checks picks object
#'
#' Enforce a single variable selection on a picks object.
#' @param picks A `picks` object
#' @returns The picks object with only being able to select one variable.
#' @export
#' @examples
#' p <- picks(datasets(), variables(multiple = TRUE))
#' pick_single_variable(p)
pick_single_variable <- function(picks) {
  var_name <- deparse(substitute(picks))
  checkmate::assert_class(picks, "picks")
  if (!is.null(picks$variables) && isTRUE(attr(picks$variables, "multiple"))) {
    warning(sprintf("`%s` accepts only a single variable selection. Forcing `teal.picks::variables(multiple) to FALSE`", var_name))
    attr(picks$variables, "multiple") <- FALSE
  }
  picks
}

fix_picks <- function(x) {
  checkmate::assert_class(x, "picks")
  attr(x, "fixed") <- TRUE
  x
}
