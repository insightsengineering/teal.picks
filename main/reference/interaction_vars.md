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
