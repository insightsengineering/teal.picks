# Resolve downstream after selected changes

@description When select input at position `i` changes:

- All slots after position i in `picks_resolved` are reset to their
  unresolved (delayed) state, because later slots depend on earlier
  ones. Slots before and at position i are kept as-is. For example,
  changing variables (i=2) resets everything after it but keeps dataset
  (i=1) intact.

- The new selection replaces the old value at slot i.

- Resolve is called, which evaluates only the slots that are still in an
  unresolved state.

- The updated picks replace the current `reactiveValue`. Thanks to this
  design reactive values are triggered only once

## Usage

``` r
.resolve(selected, slot_name, picks_resolved, old_picks, data)
```

## Arguments

- selected:

  (`vector`) rather `character`, or `factor`. `numeric(2)` for
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  based on numeric column.

- slot_name:

  (`character(1)`) one of `c("datasets", "variables", "values")`

- picks_resolved:

  (`reactiveVal`)

- old_picks:

  (`picks`)

- data:

  (`any` asserted further in `resolver`)
