# Extract datanames from list of picks

Helper to decide which datanames are needed for a teal module from the
user input.

## Usage

``` r
picks_datanames(...)
```

## Arguments

- ...:

  One or more picks object.

## Value

The names of the datasets used

## Examples

``` r
picks_datanames(
  picks(
    datasets("ADSL", "ADSL"),
    variables("SEX")
  ),
  picks(datasets("ADTTE", "ADTTE"))
)
#> [1] "ADSL"  "ADTTE"
```
