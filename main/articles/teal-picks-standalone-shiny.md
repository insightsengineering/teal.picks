# teal.picks without teal (standalone Shiny)

## Introduction

You can use
[`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
and
[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
in a plain Shiny app: pass a reactive
[`teal.data::teal_data()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
object to
[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
and combine results with
[`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
when you need merged analysis data. This mirrors what
[`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md)
does inside `teal`, without
[`teal::init()`](https://insightsengineering.github.io/teal/latest-tag/reference/init.html).

Run the `shinyApp` chunk interactively.

``` r

library(shiny)
library(teal.data)
```

    Loading required package: teal.code

``` r

library(teal.picks)

data <- teal_data()
data <- within(data, {
  ADSL <- data.frame(
    USUBJID = sprintf("S%03d", 1:8),
    AGE = sample(35:70, 8, replace = TRUE),
    stringsAsFactors = FALSE
  )
  ADLB <- data.frame(
    USUBJID = rep(sprintf("S%03d", 1:8), each = 3),
    PARAM = rep(c("ALT", "AST", "BILI"), 8),
    AVAL = round(rnorm(24, 42, 6), 1),
    stringsAsFactors = FALSE
  )
})

join_keys(data) <- join_keys(teal.data::join_key("ADSL", "ADLB", keys = "USUBJID"))

selector_default <- picks(
  datasets(choices = c("ADSL", "ADLB"), selected = "ADLB"),
  variables(
    choices = tidyselect::everything(),
    selected = c(1L, 2L),
    multiple = TRUE
  )
)
```

## Minimal Shiny app

``` r

ui <- fluidPage(
  titlePanel("Standalone picks + merge"),
  fluidRow(
    column(
      width = 4,
      picks_ui("sel", picks = selector_default)
    ),
    column(
      width = 8,
      tags$h4("Mapped variables"),
      verbatimTextOutput("mapped"),
      tags$h4("Merge preview"),
      tableOutput("merged")
    )
  )
)

server <- function(input, output, session) {
  data_r <- reactive(data)

  selectors <- list(sel = picks_srv("sel", picks = selector_default, data = data_r))

  merged <- merge_srv(
    id = "merge",
    data = data_r,
    selectors = selectors,
    output_name = "anl",
    join_fun = "dplyr::left_join"
  )

  output$mapped <- renderPrint({
    yaml::as.yaml(merged$variables())
  })

  output$merged <- renderTable({
    merged$data()[["anl"]]
  })
}

if (interactive()) {
  shinyApp(ui, server)
}
```

## Notes

- [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  expects `selectors` to be a named list of reactives (as returned by
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  for each selector).
- Define
  [`join_keys()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)
  on your `teal_data` before merging across datasets. One relationship
  between two datasets is enough:
  `join_keys(join_key("ADSL", "ADLB", keys = "USUBJID"))` is expanded by
  `teal.data` into a symmetric map so both names exist. Extra
  `join_key("DS", "DS", …)` self-keys are optional; they record
  primary-key / row grain (for example `USUBJID` + `PARAM` on long lab
  rows), which matters in full CDISC-style setups more than in this
  minimal example.
- For bookmarking,
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  stores resolved picks when `enableBookmarking = "server"` is used on
  [`shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).
- [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  filters the column(s) content chosen in
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
  If `multiple = TRUE` variables are selected, values are derived from a
  combined representation of those columns—so do not pair PARAM-only
  level choices with a selection that also includes `AVAL`. Use
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  with a single categorical column, or omit
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  when taking several columns (as in this example).
