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
    env = parent.frame()
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

#' Check if picks object has all elements fixed
#' @param picks object of class (`picks`)
#' @keywords internal
are_all_picks_fixed <- function(picks) {
  checkmate::assert_class(picks, classes = "picks")

  if (!is.null(picks$datasets)) { # case when picks has datasets
    if (all(c(is_pick_fixed(picks$datasets), is_pick_fixed(picks$variables)))) {
      picks_has_fixed_values <- TRUE
      if (!is.null(picks$values)) { # case when picks has values
        picks_has_fixed_values <- if (is_pick_fixed(picks$values)) TRUE else FALSE
      }
    } else {
      picks_has_fixed_values <- FALSE
    }
  } else { # case when picks has no datasets
    if (is_pick_fixed(picks$variables)) {
      picks_has_fixed_values <- TRUE
      if (!is.null(picks$values)) { # case when picks has values
        picks_has_fixed_values <- if (is_pick_fixed(picks$values)) TRUE else FALSE
      }
    } else {
      picks_has_fixed_values <- FALSE
    }
  }
  picks_has_fixed_values
}
