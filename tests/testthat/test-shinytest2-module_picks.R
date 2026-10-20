withr::local_options(
  list(
    shinytest2.timeout = max(
      getOption("shinytest2.timeout", default = 0),
      as.numeric(Sys.getenv("SHINYTEST2_TIMEOUT", unset = 0)),
      30 * 1000
    ),
    shinytest2.load_timeout = max(
      getOption("shinytest2.load_timeout", default = 0),
      as.numeric(Sys.getenv("SHINYTEST2_LOAD_TIMEOUT", unset = 0)),
      20 * 10000
    ),
    shinytest2.duration = max(
      getOption("shinytest2.duration", default = 0),
      as.numeric(Sys.getenv("SHINYTEST2_DURATION", unset = 0)),
      1.0 * 1000
    )
  ),
  .local_envir = testthat::test_env()
)

describe("shinytest2 picks are successfully resolved and displayed", {
  skip_if_not_installed("shinytest2")

  # Prepare data with join keys
  data <- within(teal.data::teal_data(), {
    ADSL <- teal.data::rADSL
    ADAE <- teal.data::rADAE
  })
  teal.data::join_keys(data) <- teal.data::default_cdisc_join_keys[c("ADSL", "ADAE")]

  picks <- list(
    adsl = picks(datasets("ADSL", "ADSL"), variables("AGE", fixed = FALSE)),
    adae = picks(datasets("ADAE", "ADAE"), variables(multiple = TRUE), values())
  )

  it("with a list of picks as arguments", {
    skip_if_too_deep(5)
    shiny_app <- function() {
      shiny::shinyApp(
        shiny::fluidPage(teal.picks::picks_ui("multiple", picks)),
        function(input, output, session) {
          teal.picks::picks_srv("multiple", data = reactive(data), picks = picks)
        }
      )
    }

    app_driver <- shinytest2::AppDriver$new(
      app_dir = shiny_app,
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())

    app_driver$wait_for_idle()
    expect_match(
      trimws(app_driver$get_text("#multiple-adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#multiple-adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })
  skip()

  it("with a list of picks as arguments with NULL id", {
    skip_if_too_deep(5)
    shiny_app <- function() {
      shiny::shinyApp(
        shiny::fluidPage(teal.picks::picks_ui(NULL, picks)),
        function(input, output, session) {
          teal.picks::picks_srv(NULL, data = reactive(data), picks = picks)
        }
      )
    }

    app_driver <- shinytest2::AppDriver$new(
      app_dir = shiny_app,
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())

    app_driver$wait_for_idle()
    expect_match(
      trimws(app_driver$get_text("#adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })

  it("with a list of picks as arguments with empty id", {
    skip_if_too_deep(5)
    shiny_app <- function() {
      shiny::shinyApp(
        shiny::fluidPage(teal.picks::picks_ui("", picks)),
        function(input, output, session) {
          teal.picks::picks_srv("", data = reactive(data), picks = picks)
        }
      )
    }

    app_driver <- shinytest2::AppDriver$new(
      app_dir = shiny_app,
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())

    app_driver$wait_for_idle()
    expect_match(
      trimws(app_driver$get_text("#adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })

  it("with a list of picks as arguments with empty / NULL id", {
    skip_if_too_deep(5)
    shiny_app <- function() {
      shiny::shinyApp(
        shiny::fluidPage(teal.picks::picks_ui("", picks)),
        function(input, output, session) {
          teal.picks::picks_srv(NULL, data = reactive(data), picks = picks)
        }
      )
    }

    app_driver <- shinytest2::AppDriver$new(
      app_dir = shiny_app,
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())

    app_driver$wait_for_idle()
    expect_match(
      trimws(app_driver$get_text("#adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })

  it("with individual picks as arguments", {
    skip_if_too_deep(5)
    shiny_app <- function() {
      shiny::shinyApp(
        shiny::fluidPage(teal.picks::picks_ui("adsl", picks$adsl), teal.picks::picks_ui("adae", picks$adae)),
        function(input, output, session) {
          teal.picks::picks_srv("adsl", data = reactive(data), picks = picks$adsl)
          teal.picks::picks_srv("adae", data = reactive(data), picks = picks$adae)
        }
      )
    }

    app_driver <- shinytest2::AppDriver$new(
      app_dir = shiny_app,
      name = "picks_adsl_adae",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())

    app_driver$wait_for_idle()
    expect_match(
      trimws(app_driver$get_text("#adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })
})
