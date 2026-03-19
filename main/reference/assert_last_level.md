# Assert level

Assert level

## Usage

``` r
check_last_level(x, class)

assert_last_level(x, class, .var.name = checkmate::vname(x), add = NULL)
```

## Arguments

- x:

  `picks` object

- class:

  Class of the last element of picks

- .var.name:

  \[`character(1)`\]\
  The custom name for `x` as passed to any `assert*` function. Defaults
  to a heuristic name lookup.

- add:

  \[`AssertCollection`\]\
  Collection to store assertion messages. See
  [`AssertCollection`](https://mllg.github.io/checkmate/reference/AssertCollection.html).

## Value

For `check_last_level` a logical value or a string. For
`assert_last_level` invisibly the object checked or an error.

## Examples

``` r
x <- picks(datasets(), variables(), values())
assert_last_level(x, "values")
```
