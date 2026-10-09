# Interactive picks

Creates UI and server components for interactive
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
in Shiny modules. The module is based on configuration provided via
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
and its responsibility is to determine relevant input values

The module supports both single and combined `picks`:

- Single `picks` objects for a single input

- Named lists of `picks` objects for multiple inputs

## Usage

``` r
picks_ui(id, picks, container = "badge_dropdown")

# S3 method for class 'list'
picks_ui(id = "", picks, container = "badge_dropdown")

# S3 method for class 'picks'
picks_ui(id, picks, container = "badge_dropdown")

picks_srv(id, picks, data)

# S3 method for class 'list'
picks_srv(id = "", picks, data)

# S3 method for class 'picks'
picks_srv(id, picks, data)
```

## Arguments

- id:

  (`character(1)`) Shiny module ID. Required when `picks` is a single
  `picks` object.

  Only when `picks` is a named list, `id` is optional and can be `NULL`
  or `""`:

  - If provided, it is used as a namespace prefix for each list element,
    so the input IDs become `<id>-<name>`.

  - If `NULL` or `""`, the names of the list elements are used directly
    as the input IDs. This allows each element to be placed separately
    in a custom UI (e.g. with
    `picks_ui(id = "<name>", picks = picks[["<name>"]])`), while still
    resolving all of them with a single `picks_srv()` call.

- picks:

  (`picks` or `list`) object created by
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  or a named list of such objects

- container:

  (`character(1)` or `function`) UI container type. Can be one of
  [`htmltools::tags`](https://rstudio.github.io/htmltools/reference/builder.html)
  functions. By default, elements are wrapped in a package-specific
  drop-down.

- data:

  (`reactive`) Reactive expression returning the data object to be used
  for populating choices

## Value

- `picks_ui()`: UI elements for the input controls

- `picks_srv()`: Server-side reactive logic returning the processed data

## Details

The module uses S3 method dispatch to handle different ways to provide
`picks`:

- `.picks` methods handle single \`picks“ object

- `.list` methods handle multiple `picks` objects

The UI component (`picks_ui`) creates the visual elements, while the
server component (`picks_srv`) manages the reactive logic,

## See also

[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
for creating \`picks“ objects

## Examples

``` r
library(shiny)

example_pick <- picks(
  datasets("ADSL"),
  variables(selected = c("SEX", "COUNTRY", "ARMCD"))
)
ui <- fluidPage(
  picks_ui("my_picks", picks = example_pick),
  h4("Resolved picks:"),
  verbatimTextOutput("result"),
  h4("Table:"),
  tableOutput("table")
)
server <- function(input, output, session) {
  data <- teal.data::teal_data("ADSL" = teal.data::rADSL)
  teal.data::join_keys(data) <- teal.data::default_cdisc_join_keys["ADSL"]
  selectors <- picks_srv(
    picks = list(my_picks = example_pick),
    data = reactive(data)
  )
  anl <- merge_srv("merge", data = reactive(data), selectors = selectors)
  output$result <- renderPrint(cat(gsub("\033\\[[0-9;]*m", "", format(selectors$my_picks()))))
  output$table <- renderTable(anl$data()$anl)
}

if (interactive()) {
  shinyApp(ui, server)
}
```
