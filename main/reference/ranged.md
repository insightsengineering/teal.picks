# Select a range

Helper to work with ranges. Setting `choices` or `selected` to range
using `ranged()` in any of them will automatically create a `numeric`,
`Date` or `POSIXct` input to filter. `variables(choices)` must only
refer to `numeric`, `Date`, or `POSIXct` columns. An informative error
is raised if the resolved column type is unsupported.

## Usage

``` r
ranged(min = -Inf, max = Inf)
```

## Arguments

- min:

  (`numeric(1)`) Minimal value.

- max:

  (`numeric(1)`) Maximal value.

## Examples

``` r
p <- picks(
  datasets(choices = "mtcars"),
  variables(choices = is.numeric, selected = 1),
  values(choices = ranged(), ranged(20, 30))
)
resolver(data = list("mtcars label" = mtcars), x = p)
#> Warning: None of the `choices/selected`: "mtcars"
#> are subset of: mtcars label
#> Emptying choices...
#>  <picks>
#>    <datasets>:
#>      choices: ~
#>      selected: ~
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: ~
#>      selected: ~
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE
#>    <values>:
#>      choices: ~
#>      selected: ~
#>      multiple=TRUE, ordered=FALSE, fixed=FALSE
```
