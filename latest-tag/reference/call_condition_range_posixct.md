# `POSIXct` range condition call

Compose `POSIXct` range condition call from inputs.

## Usage

``` r
call_condition_range_posixct(varname, range, timezone = Sys.timezone())
```

## Arguments

- varname:

  (`name` or `character(1)`) name of the variable.

- range:

  (`POSIXct`) range of the variable. Be aware that output uses truncated
  range format `"%Y-%m-%d %H:%M:%S"`, which means that some precision
  might be lost.

- timezone:

  (`character(1)`) specifies the time zone to be used for the
  conversion. By default
  [`Sys.timezone()`](https://rdrr.io/r/base/timezones.html) is used.

## Value

`call`.
