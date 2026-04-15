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
#' @param badge_context (`character(1)`) Variation content of the badge i.e: "primary", "secondary" ...
#' @param fixed (`logical(1)`) Whether to return a badge with dropdown (default) or simple fixed badge if set to TRUE
#' @keywords internal
badge_dropdown <- function(id, label, content, badge_context = "primary", fixed = FALSE) {
  checkmate::assert_character(badge_context)
  checkmate::assert_logical(fixed)

  ns <- shiny::NS(id)
  htmltools::tagList(
    htmltools::singleton(htmltools::tags$head(
      htmltools::includeCSS(system.file("badge-dropdown", "style.css", package = "teal.picks")),
      htmltools::includeScript(system.file("badge-dropdown", "script.js", package = "teal.picks"))
    )),
    htmltools::tags$div(
      class = "badge-dropdown-wrapper",
      htmltools::tags$span(
        id = ns("summary_badge"),
        class = sprintf("badge bg-%s rounded-pill badge-dropdown", badge_context),
        style = ifelse(fixed, "", "cursor: pointer"),
        tags$span(class = "badge-dropdown-label", label),
        if (isFALSE(fixed)) tags$span(class = "badge-dropdown-icon", bsicons::bs_icon("caret-down-fill")),
        onclick = ifelse(
                         fixed,
                         "",
                         sprintf("toggleBadgeDropdown('%s', '%s')", ns("summary_badge"), ns("inputs_container")))
      ),
      htmltools::tags$div(
        content,
        id = ns("inputs_container"),
        style = htmltools::css(
          display = "none",
          position = "absolute",
          background = "white",
          border = "1px solid #ccc",
          `border-radius` = "4px",
          `box-shadow` = "0 2px 10px rgba(0,0,0,0.1)",
          padding = "10px",
          `z-index` = "1050", # z-index set to 1000+50 to ensure that is above encoding panel on 1 column layout.
          `min-width` = "200px",
          transition = "opacity 0.2s ease",
          opacity = 0
        )
      )
    )
  )
}
