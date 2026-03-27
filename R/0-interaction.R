#' Declare interaction variable pairs for tidyselect
#'
#' Used inside tidyselect expressions to declare a pair of variables that
#' interact with each other. The pair is recorded in the selection environment
#' and the positions of both variables within the available variables are
#' returned.
#'
#' @param var1 An unquoted variable name.
#' @param var2 An unquoted variable name that interacts with `var1`.
#' @param vars Character vector of available variable names, retrieved
#'   automatically via [tidyselect::peek_vars()].
#'
#' @return An integer vector of length 2 giving the positions of `var1` and
#'   `var2` in `vars`, or `NA` where a variable is not found.
#'
#' @export
interaction_vars <- function(var1, var2, vars = tidyselect::peek_vars(fn = "interaction_vars")) {
  new_var <- c(as.character(substitute(var1)), as.character(substitute(var2)))
  result <- match(new_var, vars)
  new_operator <- structure(
    new_var,
    class = "interaction",
    var_name = sprintf("%s:%s", new_var[[1]], new_var[[2]])
  )
  select_env$operators <- select_env$operators %||% list()
  select_env$operators[[length(select_env$operators) + 1]] <- new_operator
  select_env$operators <- unique(select_env$operators)
  result
}

.operator_mutate <- function(x, new_choice, data) {
  UseMethod(".operator_mutate")
}

#' @method .operator_mutate interaction
#' @keywords internal
.operator_mutate.interaction <- function(x, new_choice, data) {
  checkmate::assert_character(x, len = 2)
  checkmate::assert_string(new_choice)
  checkmate::assert_data_frame(data)
  dplyr::mutate(
    data,
    !!new_choice := rlang::eval_bare(.operator_mutate_args(x))
  )
}

.operator_mutate_args <- function(x) {
  UseMethod(".operator_mutate_args")
}

#' @method .operator_mutate interaction
#' @keywords internal
.operator_mutate_args.interaction <- function(x) {
  checkmate::assert_character(x, len = 2)
  as.call(c(list(quote(paste)), lapply(x, as.name), list(sep = ":")))
}


# Environment to store interaction variable pairs during tidyselect evaluation
# This is used to communicate between the `interaction_vars()` function and the resolver that
# processes the picks with variables that interact.
# The resolver will look for this information in the environment to know which variables are
# meant to interact and need to be combined in the data.
select_env <- new.env(parent = emptyenv())
