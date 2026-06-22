skip_if_too_deep(5)

describe("shinytest2 badge_dropdown", {
  skip_if_not_installed("shinytest2")

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

  it("badge_dropdown is toggled when clicking and updates when selecting different values", {
    test_picks <- picks(
      datasets("iris"),
      variables(choices = c("Sepal.Length", "Sepal.Width"), selected = "Sepal.Length")
    )

    app_driver <- suppressWarnings(shinytest2::AppDriver$new(
      make_teal_picks_app(test_picks),
      name = "test-badge-dropdown"
    ))
    on.exit(app_driver$stop())
    app_driver$wait_for_idle()

    # Dropdown container is initially hidden
    expect_hidden("[id$='inputs_container']", app_driver = app_driver)

    # Click badge to open dropdown
    .teal_picks_click_summary_badge(app_driver, "pick")
    expect_visible("[id$='inputs_container']", app_driver = app_driver)

    # Click badge again to close dropdown
    .teal_picks_click_summary_badge(app_driver, "pick")
    expect_hidden("[id$='inputs_container']", app_driver = app_driver)

    # Change the selected variable (opens badge, sets value, and closes badge)
    set_teal_picks_slot(app_driver, "pick", "variables", "Sepal.Width")

    # Badge text should reflect the updated variable selection
    expect_equal(
      get_teal_picks_slot(app_driver, "pick", "variables"),
      "Sepal.Width"
    )

    # Dropdown is closed after set_teal_picks_slot
    expect_hidden("[id$='inputs_container']", app_driver = app_driver)
  })

  it("badge_fixed is visible with a lock icon and the dropdown is not toggleable", {
    test_picks <- picks(
      datasets("iris"),
      variables(choices = "Sepal.Length", selected = "Sepal.Length")
    )

    app_driver <- suppressWarnings(shinytest2::AppDriver$new(
      make_teal_picks_app(test_picks, label = "badge fixed"),
      name = "test-badge-fixed"
    ))
    on.exit(app_driver$stop())
    app_driver$wait_for_idle()

    # Fixed badge with lock icon is visible instead of the clickable dropdown badge
    expect_visible("[id$='fixed_badge']", app_driver = app_driver)

    # Container is hidden and remains hidden after clicking the fixed badge
    expect_hidden("[id$='inputs_container']", app_driver = app_driver)
    app_driver$click(selector = "[id$='fixed_badge']")
    expect_hidden("[id$='inputs_container']", app_driver = app_driver)
  })
})
