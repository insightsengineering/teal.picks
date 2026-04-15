#' Generator function so that the functions can be generated programmatically.
#' @noRd
.check_pick_generator <- function(attr_name) {
  rlang::new_function(
    rlang::pairlist2(x = ),
    substitute(
      {
        checkmate::assert_class(x, classes = c("pick"))
        checkmate::assert_flag(attr(x, attr_name, exact = TRUE))
        isTRUE(attr(x, attr_name, exact = TRUE))
      },
      env = list(attr_name = attr_name)
    ),
    env = getNamespace("teal.picks")
  )
}

#' Helper functions for pick
#' @description
#' Helper functions for pick objects generated from
#' [datasets()], [variables()] or [values()]:
#' @name helper_functions_pick
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the attribute set to `TRUE`,
#' `FALSE` otherwise.


#' @rdname helper_functions_pick
#' @description
#' - `is_pick_multiple()` checks if a pick has the `multiple` attribute set to `TRUE`.
#' @examples
#' p <- picks(datasets("iris"), variables(), values())
#'
#' is_pick_multiple(p$variables)
#' @export
is_pick_multiple <- .check_pick_generator("multiple")

#' @rdname helper_functions_pick
#' @description
#' - `is_pick_fixed()` checks if a pick has the `fixed` attribute set to `TRUE`.
#' @examples
#'
#' is_pick_fixed(p$variables)
#' @export
is_pick_fixed <- .check_pick_generator("fixed")

#' @rdname helper_functions_pick
#' @description
#' - `is_pick_ordered()` checks if a pick has the `ordered` attribute set to `TRUE`.
#' @examples
#'
#' is_pick_ordered(p$variables)
#' @export
is_pick_ordered <- .check_pick_generator("ordered")
