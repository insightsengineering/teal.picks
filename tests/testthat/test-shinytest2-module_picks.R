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
    ui <- fluidPage(teal.picks::picks_ui("multiple", picks))
    server <- function(input, output, session) {
      teal.picks::picks_srv("multiple", data = reactive(data), picks = picks)
    }

    app_driver <- shinytest2::AppDriver$new(
      app = shinyApp(ui, server),
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())
    expect_match(
      trimws(app_driver$get_text("#multiple-adsl-inputs-summary_badge")),
      "ADSL\n( )*AGE"
    )

    expect_match(
      trimws(app_driver$get_text("#multiple-adae-inputs-summary_badge")),
      "ADAE\n( )*STUDYID"
    )
  })

  it("with a list of picks as arguments with NULL id", {
    skip_if_too_deep(5)
    ui <- fluidPage(teal.picks::picks_ui(NULL, picks))
    server <- function(input, output, session) {
      teal.picks::picks_srv(NULL, data = reactive(data), picks = picks)
    }

    app_driver <- shinytest2::AppDriver$new(
      app = shinyApp(ui, server),
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())
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
    ui <- fluidPage(teal.picks::picks_ui("", picks))
    server <- function(input, output, session) {
      teal.picks::picks_srv("", data = reactive(data), picks = picks)
    }

    app_driver <- shinytest2::AppDriver$new(
      app = shinyApp(ui, server),
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())
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
    ui <- fluidPage(teal.picks::picks_ui("", picks))
    server <- function(input, output, session) {
      teal.picks::picks_srv(NULL, data = reactive(data), picks = picks)
    }

    app_driver <- shinytest2::AppDriver$new(
      app = shinyApp(ui, server),
      name = "picks_multiple",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())
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
    ui <- fluidPage(teal.picks::picks_ui("adsl", picks$adsl), teal.picks::picks_ui("adae", picks$adae))
    server <- function(input, output, session) {
      teal.picks::picks_srv("adsl", data = reactive(data), picks = picks$adsl)
      teal.picks::picks_srv("adae", data = reactive(data), picks = picks$adae)
    }

    app_driver <- shinytest2::AppDriver$new(
      app = shinyApp(ui, server),
      name = "picks_adsl_adae",
      height = 800,
      width = 1200
    )
    withr::defer(app_driver$stop())
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
