# Is picks delayed

Determine whether list of picks/picks or pick are delayed. When `"pick"`
is created it could be either:

- `quosure` when `tidyselect` helper used (delayed)

- `function` when predicate function provided (delayed)

- `atomic` when vector of choices/selected provided (eager)

## Usage

``` r
.is_delayed(x)
```

## Arguments

- x:

  (`list`, `list of picks`, `picks`, `pick`, `$choices`, `$selected`)

## Value

A `logical(1)` indicating if any of the elements in picks is delayed.,
For a single `pick`, such as
[`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
or
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
it checks if either `choices` or `selected` are delayed.
