# Convert data_extract_spec to picks

**\[experimental\]** Helper functions to ease transition between
[`teal.transform::data_extract_spec()`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
and
[`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).

## Usage

``` r
as.picks(x)

teal_transform_filter(x, label = "Filter")
```

## Arguments

- x:

  (`data_extract_spec`, `select_spec`, `filter_spec`) object to convert
  to
  [`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)

- label:

  (`character(1)`) Label of the module.

## Details

With introduction of
[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
[`teal.transform::data_extract_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
will no longer serve a primary tool to define variable choices and
default selection in teal-modules and eventually
[`teal.transform::data_extract_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
will be deprecated. To ease the transition to the new tool, we provide
`as.picks` method which can handle 1:1 conversion from
[`teal.transform::data_extract_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
to
[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
Unfortunately, when
[`teal.transform::data_extract_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
contains
[`teal.transform::filter_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/filter_spec.html)
then `as.picks` is unable to provide reliable
[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
equivalent.

## Examples

``` r
# convert des with eager select_spec
as.picks(
  teal.transform::data_extract_spec(
    dataname = "iris",
    teal.transform::select_spec(
      choices = c("Sepal.Length", "Sepal.Width", "Species"),
      selected = c("Sepal.Length", "Species"),
      multiple = TRUE,
      ordered = TRUE
    )
  )
)
#> Warning: 'NULL' are not convertible to picks
#> Warning: variables has eager choices (character) while datasets has dynamic choices. It is not guaranteed that explicitly defined choices will be a subset of data selected in a previous element.
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: Sepal.Length, Sepal.Width, Species
#>      selected: Sepal.Length, Species
#>      multiple=TRUE, ordered=TRUE, fixed=FALSE, allow-clear=TRUE

# convert des with delayed select_spec
as.picks(
  teal.transform::data_extract_spec(
    dataname = "iris",
    teal.transform::select_spec(
      choices = teal.transform::variable_choices("iris"),
      selected = teal.transform::first_choice(),
      multiple = TRUE,
      ordered = TRUE
    )
  )
)
#> Warning: 'NULL' are not convertible to picks
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: <fn>
#>      selected: 1L
#>      multiple=TRUE, ordered=TRUE, fixed=FALSE, allow-clear=FALSE

as.picks(
  teal.transform::data_extract_spec(
    dataname = "iris",
    teal.transform::select_spec(
      choices = teal.transform::variable_choices(
        "iris",
        subset = function(data) names(Filter(is.numeric, data))
      ),
      selected = teal.transform::first_choice(),
      multiple = TRUE,
      ordered = TRUE
    )
  )
)
#> Warning: 'NULL' are not convertible to picks
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: <des-dlyd>
#>      selected: <des-dlyd>
#>      multiple=TRUE, ordered=TRUE, fixed=FALSE, allow-clear=FALSE

# teal_transform_module build on teal.transform

teal_transform_filter(
  teal.transform::data_extract_spec(
    dataname = "iris",
    filter = teal.transform::filter_spec(
      vars = "Species",
      choices = c("setosa", "versicolor", "virginica"),
      selected = c("setosa", "versicolor")
    )
  )
)
#> [[1]]
#> $ui
#> function(id) {
#>         ns <- NS(id)
#>         picks_ui(ns("transformer"), picks = x, container = div)
#>       }
#> <environment: 0x5565795b6180>
#> 
#> $server
#> function (id, data) 
#> {
#>     data_out <- server(id, data)
#>     if (inherits(data_out, "reactive.event")) {
#>         warning("teal_transform_module() ", "Using eventReactive in teal_transform module server code should be avoided as it ", 
#>             "may lead to unexpected behavior. See the vignettes for more information  ", 
#>             "(`vignette(\"transform-input-data\", package = \"teal\")`).", 
#>             call. = FALSE)
#>     }
#>     decorate_err_msg(assert_reactive(data_out), pre = sprintf("From: 'teal_transform_module()':\nA 'teal_transform_module' with \"%s\" label:", 
#>         label), post = "Please make sure that this module returns a 'reactive` object containing 'teal_data' class of object.")
#> }
#> <bytecode: 0x5565795c3530>
#> <environment: 0x5565795c53e0>
#> 
#> attr(,"label")
#> [1] "Filter"
#> attr(,"datanames")
#> [1] "all"
#> attr(,"class")
#> [1] "teal_transform_module" "teal_data_module"     
#> 

teal_transform_filter(
  picks(
    datasets(choices = "iris", select = "iris"),
    variables(choices = "Species", "Species"),
    values(
      choices = c("setosa", "versicolor", "virginica"),
      selected = c("setosa", "versicolor")
    )
  )
)
#> $ui
#> function(id) {
#>         ns <- NS(id)
#>         picks_ui(ns("transformer"), picks = x, container = div)
#>       }
#> <environment: 0x5565796ad0f0>
#> 
#> $server
#> function (id, data) 
#> {
#>     data_out <- server(id, data)
#>     if (inherits(data_out, "reactive.event")) {
#>         warning("teal_transform_module() ", "Using eventReactive in teal_transform module server code should be avoided as it ", 
#>             "may lead to unexpected behavior. See the vignettes for more information  ", 
#>             "(`vignette(\"transform-input-data\", package = \"teal\")`).", 
#>             call. = FALSE)
#>     }
#>     decorate_err_msg(assert_reactive(data_out), pre = sprintf("From: 'teal_transform_module()':\nA 'teal_transform_module' with \"%s\" label:", 
#>         label), post = "Please make sure that this module returns a 'reactive` object containing 'teal_data' class of object.")
#> }
#> <bytecode: 0x5565795c3530>
#> <environment: 0x556579e8d4a0>
#> 
#> attr(,"label")
#> [1] "Filter"
#> attr(,"datanames")
#> [1] "all"
#> attr(,"class")
#> [1] "teal_transform_module" "teal_data_module"     
```
