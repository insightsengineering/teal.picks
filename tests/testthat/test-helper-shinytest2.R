make_teal_picks_app <- function(test_picks, label = "badge test") {
  data <- within(teal.data::teal_data(), iris <- iris)
  teal_app <- teal::init(
    data = data,
    modules = teal::modules(
      tm_merge(label = label, picks = list(pick = test_picks))
    )
  )
  shiny::shinyApp(ui = teal_app$ui, server = teal_app$server)
}

describe("shinytest2 helper exports", {
  skip_if_not_installed("shinytest2")

  it("app_driver_teal_picks_exports returns exported module values", {
    withr::with_envvar(c(NOT_CRAN = "true"), {
      skip_on_cran()
      test_picks <- picks(
        datasets("iris"),
        variables(choices = c("Sepal.Length", "Sepal.Width"), selected = "Sepal.Length")
      ) |>
        suppressWarnings(classes = c("picks_delayed"))

      suppressWarnings(app_driver <- shinytest2::AppDriver$new(
        make_teal_picks_app(test_picks),
        name = "test-shinytest2-exports"
      ))
      withr::defer(app_driver$stop())
      app_driver$wait_for_idle()

      exports <- app_driver_teal_picks_exports(app_driver, "pick")


      testthat::expect_true(is.list(exports))
      testthat::expect_true("picks_resolved" %in% names(exports))
    })
  })

  it("app_driver_set_teal_picks_slot updates the selected value", {
    withr::with_envvar(c(NOT_CRAN = "true"), {
      skip_on_cran()
      test_picks <- picks(
        datasets("iris"),
        variables(
          choices = c("Sepal.Length", "Sepal.Width"),
          selected = "Sepal.Length"
        )
      ) |>
        suppressWarnings(classes = c("picks_delayed"))

      suppressWarnings({
        app_driver <- shinytest2::AppDriver$new(
          make_teal_picks_app(test_picks),
          name = "test-shinytest2-set-get"
        )
        withr::defer(app_driver$stop())
        app_driver$wait_for_idle()

        testthat::expect_equal(
          app_driver_get_teal_picks_slot(app_driver, "pick", "variables"),
          "Sepal.Length"
        )
      })

      app_driver_set_teal_picks_slot(app_driver, "pick", "variables", "Sepal.Width")

      testthat::expect_equal(
        app_driver_get_teal_picks_slot(app_driver, "pick", "variables"),
        "Sepal.Width"
      )
    })
  })

  it("app_driver_expect_picks_visible and hidden reflect badge state", {
    withr::with_envvar(c(NOT_CRAN = "true"), {
      skip_on_cran()
      test_picks <- picks(
        datasets("iris"),
        variables(choices = "Sepal.Length", selected = "Sepal.Length")
      ) |>
        suppressWarnings(classes = c("picks_delayed"))

      suppressWarnings({
        app_driver <- shinytest2::AppDriver$new(
          make_teal_picks_app(test_picks, label = "badge visibility"),
          name = "test-shinytest2-visibility"
        )
        withr::defer(app_driver$stop())
        app_driver$wait_for_idle()
      })

      app_driver_expect_picks_visible("[id$='fixed_badge']", app_driver = app_driver, timeout = 1000)
      app_driver_expect_picks_hidden("[id$='inputs_container']", app_driver = app_driver, timeout = 1000)
    })
  })
})
