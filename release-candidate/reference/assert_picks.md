# Assert picks contains a specific element

Check whether a `picks` object contains at least one element of the
given class (`"datasets"`, `"variables"`, or `"values"`).

## Usage

``` r
check_picks(x, datasets = TRUE, variables = FALSE, values = FALSE)

assert_picks(
  x,
  datasets = TRUE,
  variables = FALSE,
  values = FALSE,
  .var.name = checkmate::vname(x),
  add = NULL
)
```

## Arguments

- x:

  `picks` object

- datasets:

  (`logical(1)`) whether to check for the presence of a `datasets`
  element.

- variables:

  (`logical(1)`) whether to check for the presence of a `variables`
  element

- values:

  (`logical(1)`) whether to check for the presence of a `values` element

- .var.name:

  \[`character(1)`\]\
  The custom name for `x` as passed to any `assert*` function. Defaults
  to a heuristic name lookup.

- add:

  \[`AssertCollection`\]\
  Collection to store assertion messages. See
  [`AssertCollection`](https://mllg.github.io/checkmate/reference/AssertCollection.html).

## Value

For `check_picks` a logical value or a string. For `assert_picks`
invisibly the object checked or an error.

## Examples

``` r
p <- picks(datasets(), variables(), values())
assert_picks(p, datasets = TRUE)
assert_picks(p, variables = TRUE)
assert_picks(p, values = TRUE)

p <- picks(datasets(), variables())
check_picks(p, values = TRUE)
#> [1] "Must have values() as the third element"
```
