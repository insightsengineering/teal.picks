# Resolve `picks`

Resolve iterates through each `picks` element and determines values .

## Usage

``` r
resolver(x, data)
```

## Arguments

- x:

  ([`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md))
  settings for picks.

- data:

  ([`teal.data::teal_data()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
  `environment` or `list`) any data collection supporting object
  extraction with `[[`. Used to determine values of unresolved `picks`.

## Value

resolved `picks`.

## Examples

``` r
x <- picks(datasets(tidyselect::where(is.data.frame)), variables("a", "a"))
#> Warning: variables has eager choices (character) while datasets has dynamic choices. It is not guaranteed that explicitly defined choices will be a subset of data selected in a previous element.
data <- list(
  df1 = data.frame(a = as.factor(LETTERS[1:5]), b = letters[1:5]),
  df2 = data.frame(a = LETTERS[1:5], b = 1:5),
  m = matrix()
)
resolver(x = x, data = data)
#>  <picks>
#>    <datasets>:
#>      choices: df1, df2
#>      selected: df1
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: a
#>      selected: a
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE
```
