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

p <- picks(
  datasets(is.data.frame, 2L),
  variables(is_categorical(2, 10))
)
resolver(data = list(mtcars = mtcars, iris = iris), x = p)
#>  <picks>
#>    <datasets>:
#>      choices: mtcars, iris
#>      selected: iris
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: Species
#>      selected: Species
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE
```
