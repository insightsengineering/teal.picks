# Check if datasets can be merged in topological order

Determines the topological order from join_keys, then checks that each
dataset can be joined with at least one of the previously accumulated
datasets.

## Usage

``` r
.validate_join_keys(selectors, join_keys)
```

## Arguments

- selectors:

  (`named list`) A named list of selector objects. Each element can be:

  - A `picks` object defining dataset and variable selections

  - A `reactive` expression returning a `picks` object The names of this
    list are used as identifiers for tracking which variables come from
    which selector.

- join_keys:

  (`join_keys`) The join keys object
