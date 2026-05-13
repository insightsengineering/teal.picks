#' Merge module
#'
#' Example [`teal::module`] containing interactive inputs and displaying results of merge.
#'
#' @inheritParams teal::module
#' @param picks (`list` of `picks`)
#' @return A `teal::module` object that merges datasets based on user selections and displays the results.
#' @examples
#' library(teal)
#'
#' data <- within(teal.data::teal_data(), {
#'   iris <- iris
#'   mtcars <- mtcars
#' })
#'
#' app <- init(
#'   data = data,
#'   modules = modules(
#'     modules(
#'       label = "Testing modules",
#'       tm_merge(
#'         label = "non adam",
#'         picks = list(
#'           a = picks(
#'             datasets("iris", "iris"),
#'             variables(
#'               choices = c("Sepal.Length", "Species"),
#'               selected = "Sepal.Length"
#'             ),
#'             values()
#'           )
#'         )
#'       )
#'     )
#'   )
#' )
#' if (interactive()) {
#'   shinyApp(app$ui, app$server, enableBookmarking = "server")
#' }
#'
#' @export
tm_merge <- function(label = "merge-module", picks, transformators = list()) {
  teal::module(
    label = label,
    ui = function(id, picks) {
      ns <- shiny::NS(id)
      tags$div(
        tags$div(
          class = "row g-2",
          lapply(names(picks), function(pick_name) {
            tags$div(
              class = "col-auto",
              tags$strong(tags$label(pick_name)),
              teal.picks::picks_ui(
                id = ns(pick_name),
                picks = picks[[pick_name]]
              )
            )
          })
        ),
        shiny::div(
          shiny::tags$label("Join keys"),
          shiny::verbatimTextOutput(ns("join_keys")),
          shiny::tags$label("Mapped"),
          shiny::verbatimTextOutput(ns("mapped")),
          shiny::tags$label("Source code"),
          shiny::verbatimTextOutput(ns("src")),
          shiny::tags$label("Merge result"),
          shiny::tableOutput(ns("table_merged"))
        )
      )
    },
    server = function(id, data, picks) {
      shiny::moduleServer(id, function(input, output, session) {
        selectors <- picks_srv(id, picks = picks, data = data)

        merged <- merge_srv("merge", data = data, selectors = selectors)

        table_q <- shiny::reactive({
          shiny::req(merged$data())
          within(merged$data(), anl, selectors = selectors)
        })

        output$table_merged <- shiny::renderTable({
          shiny::req(table_q())
          teal.code::get_outputs(table_q())[[1]]
        })

        output$src <- renderPrint({
          cat(teal.code::get_code(shiny::req(table_q())))
        })

        output$mapped <- renderText(yaml::as.yaml(merged$variables()))

        output$join_keys <- renderPrint(teal.data::join_keys(merged$data()))

        table_q
      })
    },
    ui_args = list(picks = picks),
    server_args = list(picks = picks),
    transformators = transformators
  )
}
