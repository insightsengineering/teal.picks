# Update reactive values with log

Update reactive values only if values differ to avoid unnecessary
reactive trigger

## Usage

``` r
.update_rv(rv, value, log)
```

## Arguments

- rv:

  (`reactiveVal`)

- value:

  (`vector`)

- log:

  (`character(1)`) message to `log_debug`
