#' Drop-down badge
#'
#' Drop-down button in a form of a badge with `bg-primary` as default style
#' Clicking badge shows a drop-down containing any `HTML` element. Folded drop-down
#' doesn't trigger display output which means that items rendered using `render*`
#' will be recomputed only when drop-down is show.
#'
#' @param id (`character(1)`) shiny module's id
#' @param label (`shiny.tag`) Label displayed on a badge.
#' @param content (`shiny.tag`) Content of a drop-down.
#' @keywords internal
badge_dropdown <- function(id, label, content) {
  ns <- shiny::NS(id)
  htmltools::tagList(
    htmltools::singleton(htmltools::tags$head(
      htmltools::includeCSS(system.file("badge-dropdown", "style.css", package = "teal.transform")),
      htmltools::includeScript(system.file("badge-dropdown", "script.js", package = "teal.transform"))
    )),
    htmltools::tags$div(
      class = "badge-dropdown-wrapper",
      htmltools::tags$span(
        id = ns("summary_badge"),
        class = "badge bg-primary rounded-pill badge-dropdown",
        tags$span(class = "badge-dropdown-label", label),
        tags$span(class = "badge-dropdown-icon", bsicons::bs_icon("caret-down-fill")),
        onclick = sprintf("toggleBadgeDropdown('%s', '%s')", ns("summary_badge"), ns("inputs_container"))
      ),
      htmltools::tags$div(
        content,
        id = ns("inputs_container"),
        style = paste(
          "visibility: hidden; opacity: 0; pointer-events: none; position: absolute; background: white;",
          "border: 1px solid #ccc; border-radius: 4px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
          "padding: 10px; z-index: 1000; min-width: 200px; transition: opacity 0.2s ease;"
        )
      )
    )
  )
}
