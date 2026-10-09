# Set a categorical teal.picks slot value.

This helper synchronizes native and bootstrap-select state and commits
via the teal.picks open/close input pulse. Use this helper only for
tests and development workflows.

## Usage

``` r
app_driver_set_teal_picks_slot(app_driver, pick_id, slot, value, wait = TRUE)
```

## Arguments

- app_driver:

  App driver object.

- pick_id:

  `character(1)` teal.picks id.

- slot:

  `character(1)` slot name.

- value:

  `NULL` or character vector of selected values.

- wait:

  `logical(1)` if `TRUE`, wait for idle after commit.

## Value

Invisibly returns `app_driver`.

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("shinytest2", quietly = TRUE)) {
  data <- within(teal.data::teal_data(), iris <- iris)
  test_picks <- picks(
    datasets("iris"),
    variables(choices = c("Sepal.Length", "Sepal.Width"), selected = "Sepal.Length")
  )
  teal_app <- teal::init(
    data = data,
    modules = teal::modules(tm_merge(label = "badge test", picks = list(pick = test_picks)))
  )
  app_driver <- suppressWarnings(shinytest2::AppDriver$new(
    shiny::shinyApp(ui = teal_app$ui, server = teal_app$server)
  ))
  on.exit(app_driver$stop())
  app_driver$wait_for_idle()
  app_driver_set_teal_picks_slot(app_driver, "pick", "variables", "Sepal.Width")
  app_driver_get_teal_picks_slot(app_driver, "pick", "variables")
}
} # }
```
