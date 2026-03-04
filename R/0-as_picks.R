#' Convert data_extract_spec to picks
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' Helper functions to ease transition between [data_extract_spec()] and [picks()].
#' @inheritParams teal::teal_transform_module
#' @param x (`data_extract_spec`, `select_spec`, `filter_spec`) object to convert to [`picks`]
#' @details
#' With introduction of [`picks`], [`data_extract_spec`] will no longer serve a primary tool to
#' define variable choices and default selection in teal-modules and eventually [`data_extract_spec`]
#' will be deprecated.
#' To ease the transition to the new tool, we provide `as.picks` method which can handle 1:1
#' conversion from [`data_extract_spec`] to [`picks`]. Unfortunately, when [`data_extract_spec`]
#' contains [`filter_spec`] then `as.picks` is unable to provide reliable [`picks`] equivalent.
#'
#' @examples
#' # convert des with eager select_spec
#' as.picks(
#'   data_extract_spec(
#'     dataname = "iris",
#'     select_spec(
#'       choices = c("Sepal.Length", "Sepal.Width", "Species"),
#'       selected = c("Sepal.Length", "Species"),
#'       multiple = TRUE,
#'       ordered = TRUE
#'     )
#'   )
#' )
#'
#' # convert des with delayed select_spec
#' as.picks(
#'   data_extract_spec(
#'     dataname = "iris",
#'     select_spec(
#'       choices = variable_choices("iris"),
#'       selected = first_choice(),
#'       multiple = TRUE,
#'       ordered = TRUE
#'     )
#'   )
#' )
#'
#' as.picks(
#'   data_extract_spec(
#'     dataname = "iris",
#'     select_spec(
#'       choices = variable_choices("iris", subset = function(data) names(Filter(is.numeric, data))),
#'       selected = first_choice(),
#'       multiple = TRUE,
#'       ordered = TRUE
#'     )
#'   )
#' )
#'
#' @export
as.picks <- function(x) { # nolint
  if (inherits(x, c("picks", "pick"))) {
    x
  } else if (checkmate::test_list(x, c("data_extract_spec", "filter_spec"))) {
    Filter(length, lapply(x, as.picks))
  } else if (inherits(x, "data_extract_spec")) {
    args <- Filter(
      length,
      list(
        datasets(choices = x$dataname, fixed = TRUE),
        as.picks(x$select),
        as.picks(x$filter)
        # filter_spec as they are not necessary linked with `select` (selected variables)
        #  as filter_spec can be specified on the variable(s) different than select_spec for example:
        #  for example: #pseudocode select = select_spec(AVAL); filter = filter_spec(PARAMCD))
      )
    )
    do.call(picks, args)
  } else if (inherits(x, "select_spec")) {
    .select_spec_to_variables(x)
  } else if (inherits(x, "filter_spec")) {
    # warning
    warning(
      "`filter_spec` are not convertible to picks - please use `transformers` argument",
      "and create `teal_transform_module` containing necessary filter. See `?teal_transform_filter`"
    )

    NULL
  }
}

#' @rdname as.picks
#' @examples
#' # teal_transform_module build on teal.transform
#'
#' teal_transform_filter(
#'   data_extract_spec(
#'     dataname = "iris",
#'     filter = filter_spec(
#'       vars = "Species",
#'       choices = c("setosa", "versicolor", "virginica"),
#'       selected = c("setosa", "versicolor")
#'     )
#'   )
#' )
#'
#' teal_transform_filter(
#'   picks(
#'     datasets(choices = "iris", select = "iris"),
#'     variables(choices = "Species", "Species"),
#'     values(
#'       choices = c("setosa", "versicolor", "virginica"),
#'       selected = c("setosa", "versicolor")
#'     )
#'   )
#' )
#'
#' @export
teal_transform_filter <- function(x, label = "Filter") {
  checkmate::assert_multi_class(x, c("data_extract_spec", "picks"))
  if (inherits(x, "data_extract_spec")) {
    lapply(.as.picks.filter(x), teal_transform_filter, label = label)
  } else {
    checkmate::assert_true("values" %in% names(x))
    teal::teal_transform_module(
      label = label,
      ui <- function(id) {
        ns <- NS(id)
        picks_ui(ns("transformer"), picks = x, container = div)
      },
      server <- function(id, data) {
        shiny::moduleServer(id, function(input, output, session) {
          selector <- picks_srv("transformer", picks = x, data = data)
          reactive({
            req(data(), selector())
            filter_call <- .make_filter_call(
              datasets = selector()$datasets$selected,
              variables = selector()$variables$selected,
              values = selector()$values$selected
            )
            teal.code::eval_code(data(), filter_call)
          })
        })
      }
    )
  }
}

.as.picks.filter <- function(x, dataname) { # nolint
  if (inherits(x, "filter_spec")) {
    if (inherits(x$choices, "delayed_data")) {
      warning(
        "filter_spec(choices) doesn't support delayed_data when using with teal_transform_filter. ",
        "Setting to all possible choices..."
      )
      x$choices <- function(x) TRUE
    }
    if (inherits(x$selected, "delayed_data")) {
      warning(
        "filter_spec(selected) doesn't support delayed_data when using with teal_transform_filter. ",
        "Setting to all possible choices..."
      )
      x$selected <- function(x) TRUE
    }
    picks(
      datasets(choices = dataname, selected = dataname),
      variables(choices = x$vars_choices, selected = x$vars_selected, multiple = FALSE), # can't be multiple
      values(choices = x$choices, selected = x$selected, multiple = x$multiple)
    )
  } else if (checkmate::test_list(x, "filter_spec")) {
    lapply(x, .as.picks.filter, dataname = dataname)
  } else if (inherits(x, "data_extract_spec")) {
    .as.picks.filter(x$filter, dataname = x$dataname)
  } else if (checkmate::test_list(x, c("data_extract_spec", "list", "NULL"))) {
    unlist(
      lapply(Filter(length, x), .as.picks.filter),
      recursive = FALSE
    )
  }
}

.make_filter_call <- function(datasets, variables, values) {
  checkmate::assert_character(datasets)
  checkmate::assert_character(variables)
  checkmate::assert_character(values)
  substitute(
    dataname <- dplyr::filter(dataname, varname %in% values),
    list(
      dataname = as.name(datasets),
      varname = if (length(variables) == 1) {
        as.name(variables)
      } else {
        as.call(
          c(
            quote(paste),
            lapply(variables, as.name),
            list(sep = ", ")
          )
        )
      },
      values = values
    )
  )
}

.select_spec_to_variables <- function(x) {
  if (length(x)) {
    variables(
      choices = if (inherits(x$choices, "delayed_data")) {
        out <- x$choices$subset
        if (is.null(out)) {
          function(x) TRUE # same effect as tidyselect::everything
        } else {
          class(out) <- "des-delayed"
          out
        }
      } else {
        x$choices
      },
      selected = if (inherits(x$selected, "delayed_choices")) {
        out <- x$selected
        class(out) <- "des-delayed"
        out
      } else if (inherits(x$selected, "delayed_data")) {
        out <- x$selected$subset
        if (is.null(out)) {
          1L
        } else {
          class(out) <- "des-delayed"
          out
        }
      } else {
        unname(x$selected)
      },
      ordered = x$ordered,
      multiple = x$multiple,
      fixed = x$fixed
    )
  }
}
