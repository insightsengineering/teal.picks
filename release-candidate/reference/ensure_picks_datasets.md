# Creation of picks object that does not override a dataset if already exists

**\[experimental\]** Utility function for applying a user-input for
variables to the data selected.

## Usage

``` r
ensure_picks_datasets(datasets = NULL, x, ...)
```

## Arguments

- datasets:

  ([`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  object) to use if `x` does not already have a dataset.

- x:

  (`pick` or `picks` object) to ensure has a dataset.

- ...:

  (`pick` or `picks` object) that will be appended to the `datasets`.

## Value

a `picks` object with a dataset, either from `x` or from `datasets` and
other information added.

## Examples

``` r
ensure_picks_datasets("ADTTE", x = picks(datasets("ADSL", "ADSL"), variables("SEX")))
#>  <picks>
#>    <datasets>:
#>      choices: ADSL
#>      selected: ADSL
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: SEX
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE
ensure_picks_datasets(datasets("ADSL", "ADSL"), x = variables("SEX", "SEX"))
#>  <picks>
#>    <datasets>:
#>      choices: ADSL
#>      selected: ADSL
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: SEX
#>      selected: SEX
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE
ensure_picks_datasets(datasets("ADSL", "ADSL"),
  x = variables("SEX", "SEX"),
  values(c("F", "M"), "F")
)
#>  <picks>
#>    <datasets>:
#>      choices: ADSL
#>      selected: ADSL
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: SEX
#>      selected: SEX
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE
#>    <values>:
#>      choices: F, M
#>      selected: F
#>      multiple=TRUE, ordered=FALSE, fixed=FALSE
```
