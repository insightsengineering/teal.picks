#' Helper functions for pick
#' @description
#' Hleper functions for pick objects generated from
#' `datasets()`, `variables()` or `values()`:
#' @name helper_functions_pick
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the attribute set to `TRUE`,
#' `FALSE` otherwise.


#' @rdname helper_functions_pick
#' @description
#' - `is_picks_multiple()` checks if a pick has the `multiple` attribute set to `TRUE`.
#' @examples
#' p <- picks(datasets("iris"), variables(), values())
#'
#' is_pick_multiple(p$variables)
#' @export
is_pick_multiple <- function(x) {
  checkmate::assert_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "multiple", exact = TRUE))
  isTRUE(attr(x, "multiple", exact = TRUE))
}

#' @rdname helper_functions_pick
#' @description
#' - `is_pick_fixed()` checks if a pick has the `fixed` attribute set to `TRUE`.
#' @examples
#'
#' is_pick_fixed(p$variables)
#' @export
is_pick_fixed <- function(x) {
  checkmate::assert_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "fixed", exact = TRUE))
  isTRUE(attr(x, "fixed", exact = TRUE))
}

#' @rdname helper_functions_pick
#' @description
#' - `is_pick_ordered()` checks if a pick has the `ordered` attribute set to `TRUE`.
#' @examples
#'
#' is_pick_ordered(p$variables)
#' @export
is_pick_ordered <- function(x) {
  checkmate::assert_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "ordered", exact = TRUE))
  isTRUE(attr(x, "ordered", exact = TRUE))
}