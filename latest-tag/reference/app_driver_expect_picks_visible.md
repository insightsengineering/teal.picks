# Expect that a CSS selector resolves to at least one visible element.

Use this helper only for tests and development workflows.

## Usage

``` r
app_driver_expect_picks_visible(selector, app_driver, timeout)

app_driver_expect_picks_hidden(selector, app_driver, timeout)
```

## Arguments

- selector:

  `character(1)` CSS selector to check.

- app_driver:

  App driver object.

- timeout:

  `numeric(1)` maximum wait time.

## Value

Called expectation result.

## Functions

- `app_driver_expect_picks_hidden()`: Check if a selector is hidden for
  a given timeout.

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
  app_driver$wait_for_idle()
  app_driver_expect_picks_hidden("[id$='inputs_container']", app_driver, timeout = 1000)
  app_driver$click(selector = "[id$='inputs-summary_badge']")
  app_driver_expect_picks_visible("[id$='inputs_container']", app_driver, timeout = 1000)
  app_driver$stop()
}
} # }
```
