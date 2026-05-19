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
  ADSL <- teal.data::rADSL
  ADLB <- teal.data::rADLB
})

join_keys(data) <- teal.data::default_cdisc_join_keys[c("ADSL", "ADLB")]
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

### Define choices and selections

Each
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
element has `choices` and `selected`. You can define them in four ways:

| Approach | Works with |
|----|----|
| Default behavior - no arguments needed for generic usage | [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) |
| Static — character vector, integer index, or numeric range | [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) |
| `tidyselect` helpers — `everything()`, `starts_with()`, `where()`, … | [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) only |
| Function — an R function applied at runtime to the data | [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md), [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) |

The sections below walk through each approach with runnable examples.

#### Defaults

Defaults depend on the slot type.

- For
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  the default `choices` are all available datasets. A
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  call needs a
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  as first positional argument, except when `check_no_dataset = FALSE`.
- For
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  the default `choices` is all variables in the selected dataset.
- For
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  the default `choices` is all values of the selected variable.
- For `selected`, the default is the first available choice, or all
  choices when `multiple = TRUE`.

``` r

picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables()
)
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: tidyselect::everything()
         selected: 1L
          [3mmultiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE [0m

``` r

picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(choices = "SEX", selected = "SEX", multiple = FALSE),
  values()
)
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: SEX
         selected: SEX
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE [0m
        [1m<values> [0m:
         choices: <fn>
         selected: <fn>
          [3mmultiple=TRUE, ordered=FALSE, fixed=FALSE [0m

#### Static choices

Pass a character vector to `choices` to enumerate options exactly. Use
`selected` to set the default. Integer indices work too (for example
`selected = 1L` means the first element of `choices`).

``` r

# Datasets — user may switch between ADSL and ADLB; ADSL is the default
p_datasets <- picks(
  datasets(
    choices  = c("ADSL", "ADLB"),
    selected = "ADSL"
  )
)

# Variables — only a named subset is offered; first column pre-selected
p_variables <- picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(
    choices  = c("AGE", "SEX", "ARM"),
    selected = "AGE",
    multiple = FALSE
  )
)

# Values — categorical filter; two levels pre-selected
p_values <- picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(choices = "SEX", selected = "SEX", multiple = FALSE),
  values(
    choices  = c("M", "F"),
    selected = "F"
  )
)

p_datasets
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL, ADLB
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=FALSE [0m

``` r

p_variables
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: AGE, SEX, ARM
         selected: AGE
          [3mmultiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE [0m

``` r

p_values
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: SEX
         selected: SEX
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE [0m
        [1m<values> [0m:
         choices: M, F
         selected: F
          [3mmultiple=TRUE, ordered=FALSE, fixed=FALSE [0m

#### `tidyselect` helpers

`tidyselect` predicates let `choices` and `selected` adapt to the actual
data at runtime instead of being hard-coded. This is supported for
[`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
and
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).

Commonly used helpers:

- [`tidyselect::everything()`](https://tidyselect.r-lib.org/reference/everything.html)
  — all items
- [`tidyselect::starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)
  /
  [`tidyselect::ends_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)
  /
  [`tidyselect::contains()`](https://tidyselect.r-lib.org/reference/starts_with.html)
  — pattern matching
- [`tidyselect::matches()`](https://tidyselect.r-lib.org/reference/starts_with.html)
  — regex matching
- `tidyselect::where(predicate)` — columns satisfying a predicate
  function
- [`tidyselect::all_of()`](https://tidyselect.r-lib.org/reference/all_of.html)
  /
  [`tidyselect::any_of()`](https://tidyselect.r-lib.org/reference/all_of.html)
  — vector-based selection (error-safe or silent)
- Integer indices such as `1L`, `1L:3L` — select by position

> Note: `tidyselect` is not supported by
> [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
> Use explicit vectors or a function there instead (see
> [Functions](#functions)).

``` r

# Datasets — offer any data.frame in the teal_data object
p_any_dataset <- picks(
  datasets(
    choices  = tidyselect::where(is.data.frame),
    selected = 1L # first dataset by default
  )
)

# Variables — all numeric columns; first one pre-selected
p_numeric_vars <- picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(
    choices  = tidyselect::where(is.numeric),
    selected = 1L,
    multiple = FALSE
  )
)

# Variables — columns whose names start with "A"; first two pre-selected
p_a_prefix <- picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(
    choices  = tidyselect::starts_with("A"),
    selected = 1L:2L,
    multiple = TRUE
  )
)

p_any_dataset
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: <fn>
         selected: 1L
          [3mmultiple=FALSE, ordered=FALSE, fixed=FALSE [0m

``` r

p_numeric_vars
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: <fn>
         selected: 1L
          [3mmultiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE [0m

``` r

p_a_prefix
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: tidyselect::starts_with("A")
         selected: <int>
          [3mmultiple=TRUE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE [0m

#### Functions

You can pass a plain R function as `choices` or `selected`. The function
receives the relevant context object (the current dataset for
[`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
and
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
the current column vector for
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md))
and must return the subset to use. This is the only runtime-dynamic
approach supported by
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).

``` r

# Variables — use the package helper is_categorical() as a column predicate.
# Without "des-delayed", the resolver calls it via vapply(data, fn, logical(1)),
# so it must accept one column and return a single logical value — which is_categorical() does.
picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(
    choices  = is_categorical(),
    selected = 1L,
    multiple = TRUE
  )
)
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: <fn>
         selected: 1L
          [3mmultiple=TRUE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE [0m

``` r

# Values — select only even ages from the AGE column.
# Functions passed to values() must carry the "des-delayed" class so the resolver
# calls them with the column vector rather than treating them as a column predicate.
even_vals <- function(x) sort(unique(x[x %% 2 == 0]))
class(even_vals) <- append(class(even_vals), "des-delayed")

p_even_ages <- picks(
  datasets(choices = "ADSL", selected = "ADSL"),
  variables(choices = "AGE", selected = "AGE", multiple = FALSE),
  values(
    choices  = even_vals,
    selected = even_vals
  )
)

p_even_ages
```

      [1m<picks> [0m
        [1m<datasets> [0m:
         choices: ADSL
         selected: ADSL
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE [0m
        [1m<variables> [0m:
         choices: AGE
         selected: AGE
          [3mmultiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE [0m
        [1m<values> [0m:
         choices: <function>
         selected: <function>
          [3mmultiple=TRUE, ordered=FALSE, fixed=FALSE [0m

#### Use of multiple to select more than one columns at once

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

See
[`?picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
for other arguments that affect how choices/selections are presented to
users regardless of using static, tidyselect or functions to define
them.

#### Choices and Selection Summary

|  | Static | `tidyselect` | Function |
|----|:--:|:--:|:--:|
| [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) | yes | yes | yes |
| [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) | yes | yes | yes |
| [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md) | yes | **no** | yes |

Use **static** choices when the set of options is fixed and known at
app-development time. Use **`tidyselect`** when you want the choices to
adapt to the shape of the data without writing a custom function. Use
**functions** when the logic is more involved, or when you need runtime
behavior for
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).

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
)

if (interactive()) {
  shinyApp(app$ui, app$server)
}
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
