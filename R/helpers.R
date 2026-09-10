#' Helper functions to check pick attributes
#' @description
#' Helper functions for pick objects generated from
#' [datasets()], [variables()] or [values()]:
#' @name helper_functions_pick
#' @param x (`datasets`, `variables` or `values`) pick to check.
#' @return `TRUE` if the pick has the attribute set to `TRUE`,
#' `FALSE` otherwise.
#' @description
#' - `is_pick_multiple()` checks if a pick has the `multiple` attribute set to `TRUE`.
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

#' Extract datanames from list of picks
#'
#' Helper to decide which datanames are needed for a teal module from the user input.
#' @param ... One or more picks object.
#' @returns The names of the datasets used
#' @export
#' @examples
#' picks_datanames(picks(datasets("ADSL", "ADSL"), variables("SEX")), picks(datasets("ADTTE", "ADTTE")))
picks_datanames <- function(...) {
  x <- rlang::dots_list(...)
  checkmate::assert_list(x, c("picks", "NULL"))
  datanames_list <- lapply(x, function(x) {
    if (is.character(x$datasets$choices)) {
      x$datasets$choices
    } else {
      NULL
    }
  })

  if (any(vapply(datanames_list, is.null, logical(1)))) {
    "all"
  } else {
    unique(unlist(datanames_list))
  }
}

#' Creation of picks object that does not override a dataset if already exists
#'
#' `r lifecycle::badge("experimental")`
#' Utility function for applying a user-input for variables to the data selected.
#' @param datasets ([`teal.picks::datasets()`] object) to use if `x` does not already have a dataset.
#' @param x (`pick` or `picks` object) to ensure has a dataset.
#' @param ... (`pick` or `picks` object) that will be appended to the `datasets`.
#' @return a `picks` object with a dataset, either from `x` or from `datasets` and other information added.
#' @export
#' @examples
#' ensure_picks_datasets("ADTTE", x = picks(datasets("ADSL", "ADSL"), variables("SEX")))
#' ensure_picks_datasets(datasets("ADSL", "ADSL"), x = variables("SEX", "SEX"))
#' ensure_picks_datasets(datasets("ADSL", "ADSL"), x = variables("SEX", "SEX"), values(c("F", "M"), "F"))
ensure_picks_datasets <- function(datasets = NULL, x, ...) {
  if (inherits(x, "picks") && !is.null(x$datasets) || is.null(x)) {
    return(x)
  }
  checkmate::assert_class(datasets, "datasets", null.ok = FALSE)
  checkmate::assert_multi_class(x, c("pick", "picks"))
  dots_arg <- rlang::dots_list(...)
  checkmate::assert_list(dots_arg, types = c("pick", "picks"), unique = TRUE, null.ok = TRUE)


  if (inherits(x, "picks")) {
    picks_args <- c(list(datasets, x$variables, x$values), dots_arg)
    do.call(
      teal.picks::picks,
      picks_args[vapply(picks_args, Negate(is.null), logical(1L))],
    )
  } else if (inherits(x, "pick")) {
    repated_pick <- vapply(dots_arg, function(p) {
      class(p)[1] %in% class(x)[1]
    }, TRUE)
    if (any(repated_pick)) {
      stop("Some pick is repeated: avoid them on ...")
    }
    do.call(teal.picks::picks, c(list(datasets, x), dots_arg))
  }
}
