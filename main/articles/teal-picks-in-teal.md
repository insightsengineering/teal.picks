# Using teal.picks in a teal application

## What this package is for

`teal.picks` helps you expose analysis choices in a `teal` Shiny app in
a way that mimicks how people think about data: first *which dataset*,
then *which columns*, and optionally *which values* to filter to. You
set all those steps at once with
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md);
the app renders the right controls and keeps selections consistent when
upstream choices change.

Typical workflow:

1.  Prepare a
    [`teal.data::teal_data()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
    object (when you relate multiple tables use `join_keys` so teal
    knows how they link).
2.  Define one or more
    [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    specs:
    [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
    optionally
    [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
    optionally
    [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    for filters or ranges.
3.  In your teal module, wire UI and server so those specs drive your
    tables, plots, or merged analysis data (see [Writing your own
    module](#writing-your-own-module)).

The examples below show the usual building blocks—not every app needs
every level.

``` r

library(teal)
library(teal.data)
library(teal.picks)

data <- teal_data()
data <- within(data, {
  ADSL <- data.frame(
    USUBJID = sprintf("S%03d", 1:12),
    AGE = sample(40:75, 12, replace = TRUE),
    SEX = rep(c("M", "F"), 6),
    stringsAsFactors = FALSE
  )
  ADLB <- data.frame(
    USUBJID = rep(sprintf("S%03d", 1:12), each = 4),
    PARAM = rep(c("ALT", "AST", "CRP", "GLU"), 12),
    AVAL = round(rnorm(48, mean = 40, sd = 8), 1),
    stringsAsFactors = FALSE
  )
})

join_keys(data) <- join_keys(teal.data::join_key("ADSL", "ADLB", keys = "USUBJID"))
```

### Choose a dataset

When the analysis can draw from more than one table, let the user pick
the active source (here, demographics vs labs).

``` r

picks_datasets <- list(
  source = picks(
    datasets(
      choices = c("ADSL", "ADLB"),
      selected = "ADLB"
    )
  )
)
```

### Choose dataset and columns

Add
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
so, after a dataset is chosen, the user picks one or more columns. You
can list names explicitly or use tidyselect-style expressions; see
[`?picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
for details.

``` r

picks_datasets_variables <- list(
  adsl_cols = picks(
    datasets(choices = "ADSL", selected = "ADSL"),
    variables(
      choices = c("USUBJID", "AGE", "SEX"),
      selected = "AGE",
      multiple = FALSE
    )
  )
)
```

### Add a value filter (levels or ranges)

[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
sits after
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
It adapts to the column type—for example category levels for a
`PARAM`-style variable, or a numeric or date range for continuous data.

``` r

picks_datasets_variables_values <- list(
  labs = picks(
    datasets(choices = "ADLB", selected = "ADLB"),
    variables(choices = "PARAM", selected = "PARAM", multiple = FALSE),
    values(
      choices = c("ALT", "AST", "CRP", "GLU"),
      selected = c("ALT", "AST"),
      multiple = TRUE
    )
  )
)
```

### Several columns at once

Use `multiple = TRUE` when analysts should pass more than one variable
into the next step (for example stratifiers or outcomes together).

``` r

picks_multiple_variables <- list(
  demo = picks(
    datasets(choices = "ADSL", selected = "ADSL"),
    variables(
      choices = c("USUBJID", "AGE", "SEX"),
      selected = c("AGE", "SEX"),
      multiple = TRUE,
      ordered = TRUE
    )
  )
)
```

## Trying these patterns inside teal

You can paste the `picks` objects above into any module that consumes
them. To quickly explore picks object(s) in teal apps, the package
includes
[`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md):
a small example teal module that connects `picks` to a merged preview
table. That is not required for normal use—it is simply a convenient
host while you learn the
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
API.

Run the next block to explore a teal app with different picks patterns

``` r

library(shiny)

app <- init(
  data = data,
  modules = modules(
    modules(
      label = "teal.picks patterns",
      tm_merge(
        label = "1. Dataset choice",
        picks = picks_datasets
      ),
      tm_merge(
        label = "2. Dataset & variables",
        picks = picks_datasets_variables
      ),
      tm_merge(
        label = "3. Dataset, variables & values",
        picks = picks_datasets_variables_values
      ),
      tm_merge(
        label = "4. Multiple variables",
        picks = picks_multiple_variables
      )
    )
  )
)

if (interactive()) {
  shinyApp(app$ui, app$server)
}
```

## Writing your own module

In real apps you usually integrate `picks` with your own
[`teal::module()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html).
Two functions do the wiring:

- [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  — place the selector controls in your picks object in your module UI
- [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  — in the module server, pass `data` as a reactive `teal_data` object;
  it returns the resolved picks (what the user chose, after any dynamic
  choices are applied).

``` r
tm_picks_preview <- function(label = "Custom picks module", picks) {
  teal::module(
    label = label,
    ui = function(id, picks) {
      ns <- shiny::NS(id)
      shiny::tagList(
        teal.picks::picks_ui(ns("sel"), picks = picks),
        shiny::tags$h5("Preview (first rows)"),
        shiny::tableOutput(ns("preview")),
        shiny::tags$h5("Resolved picks"),
        shiny::verbatimTextOutput(ns("resolved"))
      )
    },
    server = function(id, data, picks) {
      shiny::moduleServer(id, function(input, output, session) {
        resolved <- teal.picks::picks_srv("sel", picks = picks, data = data)
        preview_tbl <- shiny::reactive({
          shiny::req(data(), resolved())
          ds <- resolved()$datasets$selected
          vars <- resolved()$variables$selected
          shiny::req(length(ds) == 1L, length(vars) >= 1L)
          data()[[ds]][, vars, drop = FALSE]
        })
        output$preview <- shiny::renderTable({
          utils::head(preview_tbl(), 8L)
        })
        output$resolved <- shiny::renderPrint({
          shiny::req(resolved())
          str(resolved(), max.level = 2L, give.attr = FALSE)
        })
      })
    },
    ui_args = list(picks = picks),
    server_args = list(picks = picks),
    datanames = "ADSL"
  )
}

app <- init(
  data = data,
  modules = modules(
    tm_picks_preview(
      label = "Custom picks module",
      picks = picks_datasets_variables$adsl_cols
    )
  )
if (interactive()) {
  shinyApp(app$ui, app$server)
}
shinyApp(app$ui, app$server)
```

See
[`?picks_ui`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
and
[`?picks_srv`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
for container options and multiple named selectors.

## See also

- [`?picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  — full
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  /
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  /
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  reference.
- [`vignette("teal-picks-standalone-shiny", package = "teal.picks")`](https://insightsengineering.github.io/teal.picks/articles/teal-picks-standalone-shiny.md)
  —
  [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  /
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  in plain Shiny (no
  [`init()`](https://insightsengineering.github.io/teal/latest-tag/reference/init.html)).
- `teal` documentation for
  [`init()`](https://insightsengineering.github.io/teal/latest-tag/reference/init.html),
  [`modules()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html),
  and
  [`teal::module()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html).
