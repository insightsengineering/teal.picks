skip_if_too_deep(5)

describe("shinytest2 badge_dropdown:", {
  skip_if_not_installed("shinytest2")
  it("is visible when clicking on it multiple times", {
    test_picks <- picks(datasets("adsl"), variables())
    data <- within(teal.data::teal_data(), adsl <- teal.data::rADSL)

    app <- shiny::shinyApp(
      ui = shiny::fluidPage(
        tags$div(id = "random", "Random content"),
        picks_ui("test", picks = test_picks)
      ),
      server = function(input, output, session) {
        picks_srv("test", data = reactive(data), picks = test_picks)
      }
    )

    app_driver <- shinytest2::AppDriver$new(app, name = "test-summary_badge") |>
        expect_warning("may not be available when loading", fixed = TRUE)
    on.exit(app_driver$stop())

    app_driver$click(selector = "#test-inputs-summary_badge")
    expect_visible("#test-inputs-inputs_container", app_driver = app_driver)
    app_driver$click(selector = "#test-inputs-summary_badge")
    expect_hidden("#test-inputs-inputs_container", app_driver = app_driver)

    app_driver$click(selector = "#test-inputs-summary_badge")
    expect_visible("#test-inputs-inputs_container", app_driver = app_driver)
    app_driver$click(selector = "#random")
    expect_hidden("#test-inputs-inputs_container", app_driver = app_driver)
  })
})
