# Read all teal.picks exported values for a module namespace.

The module namespace is inferred from the summary badge id in the `DOM`,
then used to filter exported values. Use this helper only for tests and
development workflows.

## Usage

``` r
app_driver_teal_picks_exports(app_driver, pick_id)
```

## Arguments

- app_driver:

  App driver object.

- pick_id:

  `character(1)` teal.picks id.

## Value

Named list of module-scoped exported values.

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
  names(app_driver_teal_picks_exports(app_driver, "pick"))
}
} # }
```
