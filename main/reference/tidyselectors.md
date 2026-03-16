# `tidyselect` helpers

\#' **\[experimental\]** Predicate functions simplifying `picks`
specification.

## Usage

``` r
is_categorical(min.len, max.len)
```

## Arguments

- min.len:

  (`integer(1)`) minimal number of unique values

- max.len:

  (`integer(1)`) maximal number of unique values

## Examples

``` r
# select factor column but exclude foreign keys
variables(choices = is_categorical(min.len = 2, max.len = 10))
#>  <variables>
#>    choices: <fn>
#>    selected: 1L
#>    multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE
```
