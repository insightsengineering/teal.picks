# Analyse selectors and concludes a merge parameters

Analyse selectors and concludes a merge parameters

## Usage

``` r
.merge_summary_list(selectors, join_keys)
```

## Value

list containing:

- mapping (`named list`) containing selected values in each selector.
  This `mapping` is sorted according to correct datasets merge order.
  `variables` contains names of the variables in `ANL`

- join_keys (`join_keys`) updated `join_keys` containing keys of `ANL`
