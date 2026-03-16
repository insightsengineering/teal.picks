# Is picks delayed

Determine whether list of picks/picks or pick are delayed. When `"pick"`
is created it could be either:

- `quosure` when `tidyselect` helper used (delayed)

- `function` when predicate function provided (delayed)

- `atomic` when vector of choices/selected provided (eager)

## Usage

``` r
.is_delayed(x)
```

## Arguments

- x:

  (`list`, `list of picks`, `picks`, `pick`, `$choices`, `$selected`)
