# Merge module

Example
[`teal::module`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html)
containing interactive inputs and displaying results of merge.

## Usage

``` r
tm_merge(label = "merge-module", picks, transformators = list())
```

## Arguments

- label:

  (`character(1)`) Label shown in the navigation item for the module or
  module group. For
  [`modules()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html)
  defaults to `"root"`. See `Details`.

- picks:

  (`list` of `picks`)

- transformators:

  (`list` of `teal_transform_module`) that will be applied to transform
  module's data input. To learn more check
  [`vignette("transform-input-data", package = "teal")`](https://insightsengineering.github.io/teal/latest-tag/articles/transform-input-data.html).

## Examples

``` r
library(teal)
#> Loading required package: teal.slice
#> 
#> You are using teal version 1.1.0
#> 
#> Attaching package: ‘teal’
#> The following objects are masked from ‘package:teal.slice’:
#> 
#>     as.teal_slices, teal_slices

data <- within(teal.data::teal_data(), {
  iris <- iris
  mtcars <- mtcars
})

app <- init(
  data = data,
  modules = modules(
    modules(
      label = "Testing modules",
      tm_merge(
        label = "non adam",
        picks = list(
          a = picks(
            datasets("iris", "iris"),
            variables(
              choices = c("Sepal.Length", "Species"),
              selected =
              ),
            values()
          )
        )
      )
    )
  )
)
if (interactive()) {
  shinyApp(app$ui, app$server, enableBookmarking = "server")
}
```
