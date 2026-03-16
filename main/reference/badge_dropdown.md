# Drop-down badge

Drop-down button in a form of a badge with `bg-primary` as default style
Clicking badge shows a drop-down containing any `HTML` element. Folded
drop-down doesn't trigger display output which means that items rendered
using `render*` will be recomputed only when drop-down is show.

## Usage

``` r
badge_dropdown(id, label, content)
```

## Arguments

- id:

  (`character(1)`) shiny module's id

- label:

  (`shiny.tag`) Label displayed on a badge.

- content:

  (`shiny.tag`) Content of a drop-down.
