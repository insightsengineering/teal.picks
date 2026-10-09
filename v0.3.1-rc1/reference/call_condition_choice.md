# Choices condition call

Compose choices condition call from inputs.

## Usage

``` r
call_condition_choice(varname, choices)
```

## Arguments

- varname:

  (`name` or `call` or `character(1)`) name of the variable.

- choices:

  (`vector`) `varname` values to match using the `==` (single value) or
  `%in%` (vector) condition.

## Value

`call`.

## Details

`choices` can be vector of any type but for some output might be
converted:

- `factor` call is composed on choices converted to `character`;

- `Date` call is composed on choices converted to `character` using
  `format(choices)`;

- `POSIXct`, `POSIXlt` call is composed on choices converted to
  `character` using `format(choices)`.

One has to be careful here as formatted date-time variable might loose
some precision (see `format` argument in
[`format.POSIXlt()`](https://rdrr.io/r/base/strptime.html) and output
call could be insufficient for exact comparison. In this case one should
specify `varname = trunc(<varname>)` and possibly convert `choices` to
`character`).
