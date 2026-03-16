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

  additional arguments delivered to `pickerInput`
