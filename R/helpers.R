#' Check if a pick has the multiple attribute set to TRUE
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the `multiple` attribute set to `TRUE`,
#' `FALSE` otherwise.
#' @examples
#' p <- picks(datasets("iris"), variables())
#' is_pick_multiple(p$variables)
is_pick_multiple <- function(x) {
  checkmate::assert_multi_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "multiple", exact = TRUE))
  isTRUE(attr(x, "multiple", exact = TRUE))
}

#' Check if a pick has the fixed attribute set to TRUE
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the `fixed` attribute set to `
#' TRUE`, `FALSE` otherwise.
#' @examples
#' p <- picks(datasets("iris"), variables())
#' is_pick_fixed(p$variables)
is_pick_fixed <- function(x) {
  checkmate::assert_multi_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "fixed", exact = TRUE))
  isTRUE(attr(x, "fixed", exact = TRUE))
}

#' Check if a pick has the ordered attribute set to TRUE
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the `ordered` attribute set to `
#' TRUE`, `FALSE` otherwise.
#' @examples
#' p <- picks(datasets("iris"), variables())
#' is_pick_ordered(p$variables)
is_pick_ordered <- function(x) {
  checkmate::assert_multi_class(x, classes = c("pick"))
  checkmate::assert_flag(attr(x, "ordered", exact = TRUE))
  isTRUE(attr(x, "ordered", exact = TRUE))
}