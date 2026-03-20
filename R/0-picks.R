#' Choices/selected settings
#'
#' Define choices and default selection for variables. `picks` allows app-developer to specify
#' `datasets`, `variables` and `values` to be selected by app-user during Shiny session.
#' Functions are based on the idea of `choices/selected` where app-developer provides `choices`
#' and what is `selected` by default. App-user changes `selected` interactively (see [`picks_module`]).
#'
#' @param choices (`tidyselect::language` or `character`)
#'  Available values to choose.
#' @param selected (`tidyselect::language` or `character`)
#'  Choices to be selected.
#' @param multiple (`logical(1)`) if more than one selection is possible.
#' @param fixed (`logical(1)`) selection will be fixed and not possible to change interactively.
#' @param ordered (`logical(1)`) if the selected should follow the selection order. If `FALSE`
#'   `selected` returned from `srv_module_input()` would be ordered according to order in `choices`.
#' @param ... additional arguments delivered to `pickerInput`
#'
#' @details
#' # `tidyselect` support
#'
#' Both `choices` and `selected` parameters support `tidyselect` syntax, enabling dynamic
#' and flexible variable selection patterns. This allows choices to be determined at runtime
#' based on data characteristics rather than hard-coded values.
#'
#' ## Using `tidyselect` for `choices` and `selected`
#'
#' When `choices` uses `tidyselect`, the available options are determined dynamically based on actually
#' selected data:
#'
#' - `tidyselect::everything()` - All variables/datasets
#' - `tidyselect::starts_with("prefix")` - Variables starting with a prefix
#' - `tidyselect::ends_with("suffix")` - Variables ending with a suffix
#' - `tidyselect::contains("pattern")` - Variables containing a pattern
#' - `tidyselect::matches("regex")` - Variables matching a regular expression
#' - `tidyselect::where(predicate)` - Variables/datasets satisfying a predicate function
#' - `tidyselect::all_of(vars)` - All specified variables (error if missing)
#' - `tidyselect::any_of(vars)` - Any specified variables (silent if missing)
#' - Range selectors like `Sepal.Length:Petal.Width` - Variables between two positions
#' - Integer indices (e.g., `1L`, `1L:3L`, `c(1L, 3L, 5L)`) - Select by position. Be careful, must be integer!
#'
#' The `selected` parameter can use the same syntax but it will be applied to the subset defined in choices. This
#' means that `choices = is.numeric, selected = is.factor` or `choices = c("a", "b", "c"), selected = c("d", "e")`
#' will imply en empty `selected`.
#'
#' **Warning:** Using explicit character values for `selected` with dynamic `choices` may
#' cause issues if the selected values are not present in the dynamically determined choices.
#' Prefer using numeric indices (e.g., `1` for first variable) when `choices` is dynamic.
#'
#' # Structure and element dependencies
#'
#' The `picks()` function creates a hierarchical structure where elements depend on their
#' predecessors, enabling cascading reactive updates during Shiny sessions.
#'
#' ## Element hierarchy
#'
#' A `picks` object must follow this order:
#'
#' 1. **`datasets()`** - to select a dataset. Always the first element (required).
#' 2. **`variables()`** - To select columns from the chosen dataset.
#' 3. **`values()`** - To select specific values from the chosen variable(s).
#'
#' Each element's choices are evaluated within the context of its predecessor's selection.
#'
#' ## How dependencies work
#'
#' - **Fixed dataset**: When `datasets(choices = "iris")` specifies one dataset, the
#'   `variables()` choices are evaluated against that dataset columns.
#'
#' - **Multiple dataset choices**: When `datasets(choices = c("iris", "mtcars"))` allows multiple
#'   options, `variables()` choices are re-evaluated each time the user selects a different
#'   dataset. This creates a reactive dependency where variable choices update automatically.
#'
#' - **Dynamic dataset choices**: When using `datasets(choices = tidyselect::where(is.data.frame))`,
#'   all available data frames are discovered at runtime, and variable choices adapt to
#'   whichever dataset the user selects.
#'
#' - **Variable to values**: Similarly, `values()` choices are evaluated based on the
#'   selected variable(s), allowing users to filter specific levels or values. When multiple
#'   variables are selected, then values will be a concatenation of the columns.
#'
#' ## Best practices
#'
#' - Always start with `datasets()` - this is enforced by validation
#' - Use dynamic `choices` in `variables()` when working with multiple datasets to ensure
#'   compatibility across different data structures
#' - Prefer `tidyselect::everything()` or `tidyselect::where()` predicates for flexible
#'   variable selection that works across datasets with different schemas
#' - Use numeric indices for `selected` when `choices` are dynamic to avoid referencing
#'   variables that may not exist in all datasets
#'
#' ## Important: `values()` requires type-aware configuration
#'
#' ### Why `values()` is different from `datasets()` and `variables()`
#'
#' `datasets()` and `variables()` operate on named lists of objects, meaning they work with character-based
#' identifiers. This allows you to use text-based selectors like `starts_with("S")` or `contains("prefix")`
#' consistently for both datasets and variable names.
#'
#' `values()` is fundamentally different because it operates on the **actual data content** within a
#' selected variable (column). The type of data in the column determines what kind of filtering makes sense:
#'
#' - **`numeric` columns** (e.g., `age`, `height`, `price`) contain numbers
#' - **`character`/`factor` columns** (e.g., `country`, `category`, `status`) contain categorical values
#' - **`Date`/`POSIXct` columns** contain temporal data
#' - **`logical` columns** contain TRUE/FALSE values
#'
#' ### Type-specific UI controls
#'
#' The `values()` function automatically renders different UI controls based on data type:
#'
#' - **`numeric` data**: Creates a `sliderInput` for range selection
#'   - `choices` must be a numeric vector of length 2: `c(min, max)`
#'   - `selected` must be a numeric vector of length 2: `c(selected_min, selected_max)`
#'
#' - **Categorical data** (`character`/`factor`): Creates a `pickerInput` for discrete selection
#'   - `choices` can be a character vector or predicate function
#'   - `selected` can be specific values or a predicate function
#'
#' - **`Date`/`POSIXct` data**: Creates date/datetime range selectors
#'   - `choices` must be a Date or `POSIXct` vector of length 2
#'
#' - **`logical` data**: Creates a checkbox or picker for TRUE/FALSE selection
#'
#' ### Developer responsibility
#'
#' **App developers must ensure `values()` configuration matches the variable type:**
#'
#' 1. **Know your data**: Understand what type of variable(s) users might select
#' 2. **Configure appropriately**: Set `choices` and `selected` to match expected data types
#' 3. **Use predicates for flexibility**: When variable type is dynamic, use predicate functions
#'    like `function(x) !is.na(x)` (the default) to handle multiple types safely
#'
#' ### Examples of correct usage
#'
#' ```r
#' # For a numeric variable (e.g., age)
#' picks(
#'   datasets(choices = "demographic"),
#'   variables(choices = "age", multiple = FALSE),
#'   values(choices = c(0, 100), selected = c(18, 65))
#' )
#'
#' # For a categorical variable (e.g., country)
#' picks(
#'   datasets(choices = "demographic"),
#'   variables(choices = "country", multiple = FALSE),
#'   values(choices = c("USA", "Canada", "Mexico"), selected = "USA")
#' )
#'
#' # Safe approach when variable type is unknown - use predicates
#' picks(
#'   datasets(choices = "demographic"),
#'   variables(choices = tidyselect::everything(), selected = 1L),
#'   values(choices = function(x) !is.na(x), selected = function(x) !is.na(x))
#' )
#' ```
#'
#' ### Common mistakes to avoid
#'
#' ```r
#' # WRONG: Using string selectors for numeric data
#' values(choices = starts_with("5"))  # Doesn't make sense for numeric data!
#'
#' # WRONG: Providing categorical choices for a numeric variable
#' values(choices = c("low", "medium", "high"))  # Won't work if variable is numeric!
#'
#' # WRONG: Providing numeric range for categorical variable
#' values(choices = c(0, 100))  # Won't work if variable is factor/character!
#' ```
#'
#' ## Example: Three-level hierarchy
#'
#' ```r
#' picks(
#'   datasets(choices = c("iris", "mtcars"), selected = "iris"),
#'   variables(choices = tidyselect::where(is.numeric), selected = 1L),
#'   values(choices = tidyselect::everything(), selected = seq_len(10))
#' )
#' ```
#'
#' In this example:
#' - User first selects a dataset (`iris` or `mtcars`)
#' - Variable choices update to show only numeric columns from selected dataset
#' - After selecting a variable, value choices show all unique values from that column
#'
#' @examples
#' # Select columns from iris dataset using range selector
#' picks(
#'   datasets(choices = "iris"),
#'   variables(choices = Sepal.Length:Petal.Width, selected = 1L)
#' )
#'
#' # Single variable selection from iris dataset
#' picks(
#'   datasets(choices = "iris", selected = "iris"),
#'   variables(choices = c("Sepal.Length", "Sepal.Width"), selected = "Sepal.Length", multiple = FALSE)
#' )
#'
#' # Dynamic selection: any variable from iris, first selected by default
#' picks(
#'   datasets(choices = "iris", selected = "iris"),
#'   variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
#' )
#'
#' # Multiple dataset choices: variable choices will update when dataset changes
#' picks(
#'   datasets(choices = c("iris", "mtcars"), selected = "iris"),
#'   variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
#' )
#'
#' # Select from any dataset, filter by numeric variables
#' picks(
#'   datasets(choices = c("iris", "mtcars"), selected = 1L),
#'   variables(choices = tidyselect::where(is.numeric), selected = 1L)
#' )
#'
#' # Fully dynamic: auto-discover datasets and variables
#' picks(
#'   datasets(choices = tidyselect::where(is.data.frame), selected = 1L),
#'   variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
#' )
#'
#' # Select categorical variables with length constraints
#' picks(
#'   datasets(choices = tidyselect::everything(), selected = 1L),
#'   variables(choices = is_categorical(min.len = 2, max.len = 15), selected = seq_len(2))
#' )
#'
#' @export
picks <- function(...) {
  picks <- rlang::dots_list(..., .ignore_empty = "trailing")
  checkmate::assert_list(picks, types = "pick")
  if (!inherits(picks[[1]], "datasets")) {
    stop("picks() requires datasets() as the first element", call. = FALSE)
  }

  # Check if values exists and is preceded by variables
  element_classes <- vapply(picks, FUN = methods::is, FUN.VALUE = character(1))
  values_idx <- which(element_classes == "values")

  if (length(values_idx) > 0) {
    variables_idx <- which(element_classes == "variables")
    if (length(variables_idx) == 0) {
      stop("picks() requires variables() before values()", call. = FALSE)
    }
    if (values_idx != variables_idx + 1) {
      stop("values() must immediately follow variables() in picks()", call. = FALSE)
    }
  }

  previous_has_dynamic_choices <- c(
    FALSE,
    vapply(utils::head(picks, -1), FUN.VALUE = logical(1), FUN = .is_delayed)
  )
  has_eager_choices <- vapply(picks, function(x) !.is_delayed(x$choices), logical(1))

  if (any(previous_has_dynamic_choices & has_eager_choices)) {
    idx_wrong <- which(previous_has_dynamic_choices & has_eager_choices)[1]
    warning(
      element_classes[idx_wrong], " has eager choices (character) while ",
      element_classes[idx_wrong - 1], " has dynamic choices. ",
      "It is not guaranteed that explicitly defined choices will be a subset of data selected in a previous element.",
      call. = FALSE
    )
  }

  names(picks) <- element_classes
  structure(picks, class = c("picks", "list"))
}

#' @rdname picks
#' @export
datasets <- function(choices = tidyselect::everything(),
                     selected = 1L,
                     fixed = NULL,
                     ...) {
  checkmate::assert(
    .check_tidyselect(choices),
    .check_predicate(choices),
    checkmate::check_character(choices, min.len = 1)
  )
  checkmate::assert(
    .check_tidyselect(selected),
    .check_predicate(selected),
    checkmate::check_character(selected, len = 1, null.ok = TRUE)
  )

  if (is.null(fixed)) {
    fixed <- !.is_tidyselect(choices) && !.is_predicate(choices) && length(choices) == 1
  }

  out <- .pick(
    choices = if (.is_tidyselect(choices)) rlang::enquo(choices) else choices,
    selected = if (.is_tidyselect(selected)) rlang::enquo(selected) else selected,
    multiple = FALSE,
    fixed = fixed,
    ...
  )
  class(out) <- c("datasets", class(out))
  out
}

#' @rdname picks
#' @export
variables <- function(choices = tidyselect::everything(),
                      selected = 1L,
                      multiple = NULL,
                      fixed = NULL,
                      ordered = FALSE,
                      ...) {
  checkmate::assert(
    .var.name = "choices",
    .check_tidyselect(choices),
    .check_predicate(choices),
    checkmate::check_character(choices, min.len = 1)
  )
  checkmate::assert(
    .var.name = "selected",
    .check_tidyselect(selected),
    .check_predicate(selected),
    checkmate::check_character(selected, min.len = 1, null.ok = TRUE)
  )
  if (is.null(multiple)) {
    multiple <- !(.is_tidyselect(selected) || .is_predicate(selected)) && length(selected) > 1
  }
  if (is.null(fixed)) {
    fixed <- !(.is_tidyselect(choices) || .is_predicate(choices)) && length(choices) == 1
  }
  if (is.null(ordered)) {
    ordered <- formals(variables)[["ordered"]]
  }
  checkmate::assert_flag(ordered)
  checkmate::assert_flag(fixed)

  out <- .pick(
    choices = if (.is_tidyselect(choices)) rlang::enquo(choices) else choices,
    selected = if (.is_tidyselect(selected)) rlang::enquo(selected) else selected,
    multiple = multiple,
    fixed = fixed,
    ordered = ordered,
    `allow-clear` = !.is_tidyselect(selected) && !.is_predicate(selected) && (is.null(selected) || multiple),
    ...
  )
  class(out) <- c("variables", class(out))
  out
}

#' @rdname picks
#' @export
values <- function(choices = function(x) !is.na(x),
                   selected = function(x) !is.na(x),
                   multiple = TRUE,
                   fixed = NULL,
                   ...) {
  choices <- tryCatch(choices, error = function(e) {
    if (
      grepl(
        "must be used within a \\*selecting\\* function|object .+ not found|operations are possible",
        e$message
      )
    ) {
      stop("`values()` does not support tidyselect expressions in `choices`.", call. = FALSE)
    }
    stop(e)
  })
  checkmate::assert(
    .var.name = "choices",
    .check_predicate(choices),
    checkmate::check_character(choices, min.len = 1, unique = TRUE),
    checkmate::check_factor(choices, min.len = 1),
    checkmate::check_logical(choices, min.len = 1, unique = TRUE),
    checkmate::check_numeric(choices, len = 2, sorted = TRUE, finite = TRUE),
    checkmate::check_date(choices, len = 2), # should be sorted but determine
    checkmate::check_posixct(choices, len = 2)
  )
  checkmate::assert(
    .var.name = "selected",
    .check_predicate(selected),
    checkmate::check_null(selected),
    checkmate::check_character(selected, min.len = 1, unique = TRUE),
    checkmate::check_factor(selected, min.len = 1),
    checkmate::check_logical(selected, min.len = 1, unique = TRUE),
    checkmate::check_numeric(selected, len = 2, sorted = TRUE, finite = TRUE),
    checkmate::check_date(selected, len = 2),
    checkmate::check_posixct(selected, len = 2)
  )

  if (is.null(fixed)) {
    fixed <- !.is_predicate(choices) && length(choices) == 1
  }
  if (is.null(multiple)) {
    multiple <- formals(values)[["multiple"]]
  }
  checkmate::assert_flag(fixed)
  checkmate::assert_flag(multiple)

  out <- .pick(
    choices = choices,
    selected = selected,
    multiple = multiple,
    fixed = fixed,
    ...
  )
  class(out) <- c("values", class(out))
  out
}

#' Pick class constructor
#'
#' Create a `pick` object
#' @inheritParams picks
#' @keywords internal
.pick <- function(choices,
                  selected,
                  multiple = length(selected) > 1,
                  ordered = FALSE,
                  fixed = FALSE,
                  ...) {
  is_choices_delayed <- rlang::is_quosure(choices) || .is_predicate(choices)
  is_selected_eager <- is.character(selected)
  if (is_choices_delayed && is_selected_eager) {
    warning(
      deparse(sys.call(-1)),
      "\n - Setting explicit `selected` while `choices` are delayed (set using `tidyselect`) doesn't ",
      "guarantee that `selected` is a subset of `choices`.",
      call. = FALSE
    )
  }

  if (is.character(choices) && is.character(selected) && any(!selected %in% choices)) {
    not_in_choices <- setdiff(selected, choices)
    stop(sprintf(
      "Some `selected`:{%s}\nare not a subset of `choices`: {%s}",
      toString(sQuote(not_in_choices)),
      toString(sQuote(choices))
    ))
  }

  out <- structure(
    list(choices = choices, selected = selected),
    multiple = multiple,
    ordered = ordered,
    fixed = fixed,
    ...,
    class = "pick"
  )
}

#' Is an object created using `tidyselect`
#'
#' @description
#' `choices` and `selected` can be provided using `tidyselect`, (e.g. [tidyselect::everything()]
#' [tidyselect::where()], [tidyselect::starts_with()]). These functions can't be called
#' independently but rather as an argument of function which consumes them.
#' `.is_tidyselect` safely determines if `x` can be evaluated with `tidyselect::eval_select()`
#' @param x `choices` or `selected`
#' @return `logical(1)`
#' @keywords internal
.is_tidyselect <- function(x) {
  out <- suppressWarnings(tryCatch(x, error = function(e) e))
  inherits(out, "error") && grepl("must be used within a \\*selecting\\* function", out$message) || # e.g. everything
    inherits(out, "error") && grepl("object .+ not found", out$message) || # e.g. var:var2
    inherits(out, "error") && grepl("operations are possible", out$message) || # e.g. where() | where()
    checkmate::test_integerish(out, min.len = 1) # e.g. 1L:5L
}

.is_predicate <- function(x) {
  !.is_tidyselect(x) &&
    (
      checkmate::test_function(x, nargs = 1) ||
        checkmate::test_function(x) && identical(names(formals(x)), "...")
    )
}

.check_tidyselect <- function(x) {
  if (!.is_tidyselect(x)) {
    "choices/selected has not been created using tidyselect-helper"
  } else {
    TRUE
  }
}

.check_predicate <- function(x) {
  if (!.is_predicate(x)) {
    "choices/selected has not been created using predicate function (single arg function returning TRUE or FALSE)"
  } else {
    TRUE
  }
}


#' Is picks delayed
#'
#' Determine whether list of picks/picks or pick are delayed.
#' When `"pick"` is created it could be either:
#' - `quosure` when `tidyselect` helper used (delayed)
#' - `function` when predicate function provided (delayed)
#' - `atomic` when vector of choices/selected provided (eager)
#' @param x (`list`, `list of picks`, `picks`, `pick`, `$choices`, `$selected`)
#' @keywords internal
.is_delayed <- function(x) {
  UseMethod(".is_delayed")
}

#' @export
.is_delayed.list <- function(x) {
  any(vapply(x, .is_delayed, logical(1)))
}

#' @export
.is_delayed.pick <- function(x) {
  .is_delayed(x$choices) | .is_delayed(x$selected)
}

#' @export
.is_delayed.default <- function(x) {
  rlang::is_quosure(x) |
    is.function(x)
}
