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
picks_ui(id, picks, container)

# S3 method for class 'picks'
picks_ui(id, picks, container)

picks_srv(id = "", picks, data)

# S3 method for class 'list'
picks_srv(id, picks, data)

# S3 method for class 'picks'
picks_srv(id, picks, data)
```

## Arguments

- id:

  (`character(1)`) Shiny module ID

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
