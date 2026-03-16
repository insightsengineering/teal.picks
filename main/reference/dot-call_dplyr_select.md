# `dplyr::select` call

Create
[`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
call from `dataname` and `variables`

## Usage

``` r
.call_dplyr_select(dataname, variables)
```

## Arguments

- dataname:

  (`character(1)`) name of the dataset

- variables:

  (`list` of `character`) variables to select. If list is named then
  variables will be renamed if their name is different than its value
  (this produces a call `select(..., <name> = <value>)`).
