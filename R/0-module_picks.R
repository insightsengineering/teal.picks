#' Interactive picks
#'
#' @description
#'
#' Creates UI and server components for interactive [picks()] in Shiny modules. The module is based on
#' configuration provided via [picks()] and its responsibility is to determine relevant input
#' values
#'
#'
#' The module supports both single and combined `picks`:
#' - Single `picks` objects for a single input
#' - Named lists of `picks` objects for multiple inputs
#'
#' @param id (`character(1)`) Shiny module ID
#' @param picks (`picks` or `list`) object created by `picks()` or a named list of such objects
#' @param container (`character(1)` or `function`) UI container type. Can be one of `htmltools::tags`
#' functions. By default, elements are wrapped in a package-specific drop-down.
#' @param data (`reactive`) Reactive expression returning the data object to be used for populating choices
#'
#' @return
#' - `picks_ui()`: UI elements for the input controls
#' - `picks_srv()`: Server-side reactive logic returning the processed data
#'
#' @details
#' The module uses S3 method dispatch to handle different ways to provide `picks`:
#' - `.picks` methods handle single `picks`` object
#' - `.list` methods handle multiple `picks` objects
#'
#' The UI component (`picks_ui`) creates the visual elements, while the
#' server component (`picks_srv`) manages the reactive logic,
#'
#' @seealso [picks()] for creating `picks`` objects
#'
#' @name picks_module
NULL

#' @rdname picks_module
#' @export
picks_ui <- function(id, picks, container = "badge_dropdown") {
  checkmate::assert_string(id)
  UseMethod("picks_ui", picks)
}

#' @rdname picks_module
#' @export
picks_ui.list <- function(id, picks, container) {
  checkmate::assert_list(picks, names = "unique")
  ns <- shiny::NS(id)
  sapply(
    Filter(length, names(picks)),
    USE.NAMES = TRUE,
    function(name) picks_ui(ns(name), picks[[name]], container = container)
  )
}

#' @rdname picks_module
#' @export
picks_ui.picks <- function(id, picks, container) {
  ns <- shiny::NS(id)
  badge_label <- shiny::uiOutput(ns("summary"), container = htmltools::tags$span)

  content <- lapply(picks, function(x) .pick_ui(id = ns(methods::is(x))))
  htmltools::tags$div(
    if (missing(container)) {
      badge_dropdown(id = ns("inputs"), label = badge_label, htmltools::tagList(content))
    } else {
      if (!any(sapply(htmltools::tags, identical, container))) {
        stop("Container should be one of `htmltools::tags`")
      }
      container(content)
    }
  )
}

#' @rdname picks_module
#' @export
picks_srv <- function(id = "", picks, data) {
  checkmate::assert_string(id)
  checkmate::assert_class(data, "reactive")
  UseMethod("picks_srv", picks)
}

#' @rdname picks_module
#' @export
picks_srv.list <- function(id, picks, data) {
  checkmate::assert_named(picks, type = "unique")
  sapply(
    names(Filter(length, picks)),
    USE.NAMES = TRUE,
    function(name) picks_srv(name, picks[[name]], data)
  )
}

#' @rdname picks_module
#' @export
picks_srv.picks <- function(id, picks, data) {
  moduleServer(id, function(input, output, session) {
    picks_resolved <- shiny::reactiveVal(
      restoreValue(
        session$ns("picks"),
        resolver(picks, shiny::isolate(data()))
      )
    )
    session$onBookmark(function(state) {
      logger::log_debug("picks_srv@onBookmark: storing current picks")
      state$values$picks <- picks_resolved()
    })

    badge <- shiny::reactive({
      lapply(
        picks_resolved(),
        function(x) {
          label <- if (inherits(x, "values")) {
            if (!setequal(x$choices, x$selected)) {
              bsicons::bs_icon("funnel")
            }
          } else if (length(x$selected)) {
            toString(x$selected)
          } else {
            "~"
          }
          label
        }
      )
    })

    output$summary <- shiny::renderUI(tagList(badge()))

    Reduce(
      function(this_data, slot_name) { # this_data is a (drilled-down) data for current pick
        choices <- reactiveVal(isolate(picks_resolved())[[slot_name]]$choices)
        selected <- reactiveVal(isolate(picks_resolved())[[slot_name]]$selected)
        all_choices <- reactive(determine(x = picks[[slot_name]], data = this_data())$x$choices)

        observeEvent(all_choices(), ignoreInit = TRUE, {
          current_choices <- picks_resolved()[[slot_name]]$choices
          current_selected <- picks_resolved()[[slot_name]]$selected
          new_selected <- if (is.numeric(current_selected) && is.numeric(all_choices())) {
            c(
              max(current_selected[1], all_choices()[1], na.rm = TRUE),
              min(current_selected[2], all_choices()[2], na.rm = TRUE)
            )
          } else {
            intersect(current_selected, all_choices())
          }

          .update_rv(
            selected, new_selected,
            sprintf("picks_srv@1 %s$%s$selected is outside of the possible choices", id, slot_name)
          )
          .update_rv(
            choices, all_choices(),
            sprintf("picks_srv@1 %s$%s$choices is outside of the possible choices", id, slot_name)
          )
        })

        observeEvent(picks_resolved()[[slot_name]], ignoreInit = TRUE, ignoreNULL = FALSE, {
          .update_rv(choices, picks_resolved()[[slot_name]]$choices, log = "picks_srv@1 update input choices")
          .update_rv(selected, picks_resolved()[[slot_name]]$selected, log = "picks_srv@1 update input selected")
        })

        args <- attributes(picks[[slot_name]])
        .pick_srv(
          id = slot_name,
          pick_type = slot_name,
          choices = choices,
          selected = selected,
          args = args[!names(args) %in% c("names", "class")],
          data = this_data
        )

        # this works as follows:
        #  Each observer is observes input$selected of i-th element of picks ($datasets, $variables, ...)
        shiny::observeEvent(
          selected(),
          ignoreInit = TRUE, # because picks_resolved is already resolved and `selected()` is being set
          ignoreNULL = FALSE, # because input$selected can be empty
          {
            .resolve(
              selected(),
              slot_name = slot_name,
              picks_resolved = picks_resolved,
              old_picks = picks,
              data = data() # data() object needed as we resolve the WHOLE picks INSTEAD OF one picks element.
            )
          }
        )

        reactive(.extract(x = picks_resolved()[[slot_name]], this_data()))
      },
      x = names(picks),
      init = data
    )

    picks_resolved
  })
}

.pick_ui <- function(id) {
  ns <- shiny::NS(id)
  uiOutput(ns("selected_container"))
}

.pick_srv <- function(id, pick_type, choices, selected, data, args) {
  checkmate::assert_string(id)
  checkmate::assert_class(choices, "reactiveVal")
  checkmate::assert_class(selected, "reactiveVal")
  checkmate::assert_list(args)

  shiny::moduleServer(id, function(input, output, session) {
    is_numeric <- reactive(is.numeric(choices()))
    choices_opt_content <- reactive({
      if (pick_type != "values") {
        sapply(
          choices(),
          function(choice) {
            icon <- toString(icon(.picker_icon(data()[[choice]]), lib = "font-awesome"))
            label <- attr(data()[[choice]], "label")
            paste(
              icon,
              choice,
              if (!is.null(label) && !is.na(label) && !identical(label, choice)) {
                toString(tags$small(label, class = "text-muted"))
              }
            )
          }
        )
      }
    })

    output$selected_container <- renderUI({
      logger::log_debug(".pick_srv@1 rerender {pick_type} input")
      .validate_is_eager(choices())
      .validate_is_eager(selected())
      if (isTRUE(args$fixed) || length(choices()) <= 1) {} else if (is_numeric()) {
        .pick_ui_numeric(
          session$ns("range"),
          label = sprintf("Select %s range:", pick_type),
          choices = choices(),
          selected = selected(),
          args = args
        )
      } else {
        .pick_ui_categorical(
          session$ns("selected"),
          label = sprintf("Select %s:", pick_type),
          choices = choices(),
          selected = selected(),
          multiple = args$multiple,
          choicesOpt = list(content = isolate(choices_opt_content())),
          args = args[!names(args) %in% c("multiple")]
        )
      }
    }) |> bindEvent(is_numeric(), choices()) # never change on selected()

    # for numeric
    range_debounced <- reactive(input$range) |> debounce(1000)
    shiny::observeEvent(range_debounced(), {
      .update_rv(selected, input$range, log = ".pick_srv@2 update selected after input changed")
    })

    # for non-numeric
    shiny::observeEvent(input$selected_open, {
      if (!isTRUE(input$selected_open)) {
        # ↓ pickerInput returns "" when nothing selected. This can cause failure during col select (x[,""])
        new_selected <- if (length(input$selected) && !identical(input$selected, "")) as.vector(input$selected)
        if (args$ordered) {
          new_selected <- c(intersect(selected(), new_selected), setdiff(new_selected, selected()))
        }
        .update_rv(selected, new_selected, log = ".pick_srv@1 update selected after input changed")
      }
    })
    selected
  })
}


.pick_ui_numeric <- function(id, label, choices, selected, args) {
  shinyWidgets::numericRangeInput(
    inputId = id,
    label = label,
    min = unname(choices[1]),
    max = unname(utils::tail(choices, 1)),
    value = unname(selected)
  )
}

.pick_ui_categorical <- function(id, label, choices, selected, multiple, choicesOpt, args) { # nolint
  htmltools::div(
    style = "max-width: 500px;",
    shinyWidgets::pickerInput(
      inputId = id,
      label = label,
      choices = choices,
      selected = selected,
      multiple = multiple,
      choicesOpt = choicesOpt,
      options = c(
        list(
          "actions-box" = !multiple,
          "live-search" = length(choices) > 10,
          "none-selected-text" = "- Nothing selected -",
          "show-subtext" = TRUE
        ),
        args
      )
    )
  )
}

#' Update reactive values with log
#'
#' Update reactive values only if values differ to avoid unnecessary reactive trigger
#' @param rv (`reactiveVal`)
#' @param value (`vector`)
#' @param log (`character(1)`) message to `log_debug`
#' @keywords internal
.update_rv <- function(rv, value, log) {
  if (!isTRUE(all.equal(rv(), value, tolerance = 1e-15))) { # tolerance 1e-15 is a max precision in widgets.
    logger::log_debug(log)
    rv(value)
  }
}

#' Resolve downstream after selected changes
#'
#'  @description
#'  When i-th select input changes then
#'   - picks_resolved containing current state is being unresolved but only after the i-th element as
#'     values are sequentially dependent. For example if variables (i=2) is selected we don't want
#'     to unresolve (restart) dataset.
#'   - new value (selected) is replacing old value in current slot (i)
#'   - we call resolve which resolves only "unresolved" (delayed) values
#'   - new picks is replacing `reactiveValue`
#' Thanks to this design reactive values are triggered only once
#' @param selected (`vector`) rather `character`, or `factor`. `numeric(2)` for `values()` based on numeric column.
#' @param slot_name (`character(1)`) one of `c("datasets", "variables", "values")`
#' @param picks_resolved (`reactiveVal`)
#' @param old_picks (`picks`)
#' @param data (`any` asserted further in `resolver`)
#' @keywords internal
.resolve <- function(selected, slot_name, picks_resolved, old_picks, data) {
  checkmate::assert_vector(selected, null.ok = TRUE)
  checkmate::assert_string(slot_name)
  checkmate::assert_class(picks_resolved, "reactiveVal")
  checkmate::assert_class(old_picks, "picks")
  if (isTRUE(all.equal(selected, picks_resolved()[[slot_name]]$selected, tolerance = 1e-15))) {
    return(NULL)
  }
  logger::log_info("picks_server@1 selected has changed. Resolving downstream...")

  new_picks_unresolved <- old_picks
  # ↓ everything after `slot_idx` is to resolve
  slot_idx <- which(names(old_picks) == slot_name)
  new_picks_unresolved[seq_len(slot_idx - 1)] <- picks_resolved()[seq_len(slot_idx - 1)]
  new_picks_unresolved[[slot_idx]]$selected <- selected

  resolver_warnings <- character(0)
  new_picks_resolved <- withCallingHandlers(
    resolver(new_picks_unresolved, data),
    warning = function(w) {
      resolver_warnings <<- paste(conditionMessage(w), collapse = " ")
    }
  )
  if (length(resolver_warnings)) {
    showNotification(resolver_warnings, type = "error")
  }

  picks_resolved(new_picks_resolved)
}

#' Restore value from bookmark.
#'
#' Get value from bookmark or return default.
#'
#' Bookmarks can store not only inputs but also arbitrary values.
#' These values are stored by `onBookmark` callbacks and restored by `onBookmarked` callbacks,
#' and they are placed in the `values` environment in the `session$restoreContext` field.
#' Using `teal_data_module` makes it impossible to run the callbacks
#' because the app becomes ready before modules execute and callbacks are registered.
#' In those cases the stored values can still be recovered from the `session` object directly.
#'
#' Note that variable names in the `values` environment are prefixed with module name space names,
#' therefore, when using this function in modules, `value` must be run through the name space function.
#'
#' @param value (`character(1)`) name of value to restore
#' @param default fallback value
#'
#' @return
#' In an application restored from a server-side bookmark,
#' the variable specified by `value` from the `values` environment.
#' Otherwise `default`.
#'
#' @keywords internal
#'
restoreValue <- function(value, default) { # nolint: object_name.
  checkmate::assert_character("value")
  session_default <- shiny::getDefaultReactiveDomain()
  session_parent <- .subset2(session_default, "parent")
  session <- if (is.null(session_parent)) session_default else session_parent

  if (isTRUE(session$restoreContext$active) && exists(value, session$restoreContext$values, inherits = FALSE)) {
    session$restoreContext$values[[value]]
  } else {
    default
  }
}

#' `pickerInput` choices icons
#'
#' Icons describing a class of the choice
#' @param x (`any`) object which class will determine icon
#' @return html-tag in form of `character(1)`
#' @keywords internal
.picker_icon <- function(x) {
  UseMethod(".picker_icon")
}

#' @keywords internal
#' @export
.picker_icon.numeric <- function(x) "arrow-up-1-9"

#' @keywords internal
#' @export
.picker_icon.integer <- function(x) "arrow-up-1-9"

#' @keywords internal
#' @export
.picker_icon.logical <- function(x) "pause"

#' @keywords internal
#' @export
.picker_icon.Date <- function(x) "calendar"

#' @keywords internal
#' @export
.picker_icon.POSIXct <- function(x) "calendar"

#' @keywords internal
#' @export
.picker_icon.POSIXlt <- function(x) "calendar"

#' @keywords internal
#' @export
.picker_icon.factor <- function(x) "chart-bar"

#' @keywords internal
#' @export
.picker_icon.character <- function(x) "font"

#' @keywords internal
#' @export
.picker_icon.primary_key <- function(x) "key"

#' @keywords internal
#' @export
.picker_icon.data.frame <- function(x) "table"

#' @keywords internal
#' @export
.picker_icon.default <- function(x) "circle-question"
