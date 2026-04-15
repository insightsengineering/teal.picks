# Helper functions for pick

Helper functions for pick objects generated from
[`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
or
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md):

- `is_pick_multiple()` checks if a pick has the `multiple` attribute set
  to `TRUE`.

&nbsp;

- `is_pick_fixed()` checks if a pick has the `fixed` attribute set to
  `TRUE`.

&nbsp;

- `is_pick_ordered()` checks if a pick has the `ordered` attribute set
  to `TRUE`.

## Usage

``` r
is_pick_multiple(x)

is_pick_fixed(x)

is_pick_ordered(x)
```

## Arguments

- x:

  (`datasets`, `variables` or `values`) pick to check.

## Value

`TRUE` if the pick has the attribute set to `TRUE`, `FALSE` otherwise.

## Examples

``` r
p <- picks(datasets("iris"), variables(), values())

is_pick_multiple(p$variables)
#> [1] FALSE

is_pick_fixed(p$variables)
#> [1] FALSE

is_pick_ordered(p$variables)
#> [1] FALSE
```
