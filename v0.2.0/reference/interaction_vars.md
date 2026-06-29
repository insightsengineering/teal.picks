# Declare interaction variable pairs for `tidyselect`

Used inside `tidyselect` expressions to declare a pair of variables that
interact with each other. The pair is recorded in the selection
environment and the positions of both variables within the available
variables are returned.

## Usage

``` r
interaction_vars(
  var1,
  var2,
  vars = tidyselect::peek_vars(fn = "interaction_vars")
)
```

## Arguments

- var1:

  An unquoted variable name.

- var2:

  An unquoted variable name that interacts with `var1`.

- vars:

  Character vector of available variable names, retrieved automatically
  via
  [`tidyselect::peek_vars()`](https://tidyselect.r-lib.org/reference/peek_vars.html).

## Value

An integer vector of length 2 giving the positions of `var1` and `var2`
in `vars`, or `NA` where a variable is not found.

## Examples

``` r
picks(
  datasets("ADAE"),
  variables(
    c(AGE, RACE, interaction_vars("COUNTRY", "RACE")),
    selected = "COUNTRY:RACE",
    multiple = TRUE
  ),
  values()
)
#> Warning: do.call(.pick, c(list(choices = if (.is_tidyselect(choices)) rlang::enquo(choices) else choices, selected = if (.is_tidyselect(selected)) rlang::enquo(selected) else selected, multiple = multiple, fixed = fixed, ordered = ordered), dots))
#>  - Setting explicit `selected` while `choices` are delayed (set using `tidyselect`) doesn't guarantee that `selected` is a subset of `choices`.
#>  <picks>
#>    <datasets>:
#>      choices: ADAE
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: c(AGE, RACE, interaction_vars("COUNTRY", "RACE"))
#>      selected: COUNTRY:RACE
#>      multiple=TRUE, ordered=FALSE, fixed=FALSE, allow-clear=TRUE
#>    <values>:
#>      choices: <fn>
#>      selected: <fn>
#>      multiple=TRUE, ordered=FALSE, fixed=FALSE
```
