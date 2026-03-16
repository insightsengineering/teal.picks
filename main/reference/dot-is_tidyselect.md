# Is an object created using `tidyselect`

`choices` and `selected` can be provided using `tidyselect`, (e.g.
[`tidyselect::everything()`](https://tidyselect.r-lib.org/reference/everything.html)
[`tidyselect::where()`](https://tidyselect.r-lib.org/reference/where.html),
[`tidyselect::starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)).
These functions can't be called independently but rather as an argument
of function which consumes them. `.is_tidyselect` safely determines if
`x` can be evaluated with
[`tidyselect::eval_select()`](https://tidyselect.r-lib.org/reference/eval_select.html)

## Usage

``` r
.is_tidyselect(x)
```

## Arguments

- x:

  `choices` or `selected`

## Value

`logical(1)`
