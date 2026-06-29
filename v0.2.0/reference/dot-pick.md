# Pick class constructor

Create a `pick` object

## Usage

``` r
.pick(
  choices,
  selected,
  multiple = length(selected) > 1,
  ordered = FALSE,
  fixed = FALSE,
  ...
)
```

## Arguments

- choices:

  ([`tidyselect::language`](https://tidyselect.r-lib.org/reference/language.html)
  or `character`) Available values to choose.

- selected:

  ([`tidyselect::language`](https://tidyselect.r-lib.org/reference/language.html)
  or `character`) Choices to be selected.

- multiple:

  (`logical(1)`) if more than one selection is possible.

- ordered:

  (`logical(1)`) if the selected should follow the selection order. If
  `FALSE` `selected` returned from `srv_module_input()` would be ordered
  according to order in `choices`.

- fixed:

  (`logical(1)`) selection will be fixed and not possible to change
  interactively.

- ...:

  for `picks(...)`: hierarchical structure that contains
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  as first element and optionally
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  and
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)

  for `variables(...)` and `values(...)`: additional arguments delivered
  to `pickerInput`, see
  [`shinyWidgets::pickerOptions()`](https://dreamrs.github.io/shinyWidgets/reference/pickerOptions.html)
  for available options as well as documentation for `bootstrap-select`
  `v1.14.0-beta3` or higher for newer options (e.g., `allow-clear` that
  allows clearing the selection).

## Value

`pick` generic object that is used by
[`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
[`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
and
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
to create objects of corresponding classes.
