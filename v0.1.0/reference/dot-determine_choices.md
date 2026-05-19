# Evaluate delayed choices

Evaluate delayed choices

## Usage

``` r
.determine_choices(x, data)

.determine_selected(x, data, multiple = FALSE)

.determine_delayed(x, data)

.possible_choices(data)
```

## Arguments

- x:

  (`character`, `quosure`, `function(x)`) to determine `data` elements
  to extract.

- data:

  (`list`, `data.frame`, `vector`)

- multiple:

  (`logical(1)`) whether multiple selection is possible.

## Value

`character` containing names/levels of `data` elements which match `x`,
with two differences:

- `.determine_choices` returns vector named after data labels

- `.determine_selected` cuts vector to scalar when `multiple = FALSE`

## Details

### Various ways to evaluate choices/selected.

Function resolves `x` to determine `choices` or `selected`. `x` is
matched in multiple ways with `data` to return valid choices:

- `x (character)`: values are matched with names of data and only
  intersection is returned.

- `x (tidyselect-helper)`: using
  [tidyselect::eval_select](https://tidyselect.r-lib.org/reference/eval_select.html)

- `x (function)`: function is executed on each element of `data` to
  determine where function returns TRUE

Mechanism is robust in a sense that it never fails (`tryCatch`) and
returns `NULL` if no-match found. `NULL` in
[`determine()`](https://insightsengineering.github.io/teal.picks/reference/determine.md)
is handled gracefully, by setting `NULL` to all following components of
`picks`.

In the examples below you can replace `.determine_delayed` with
`.determine_choices` or `.determine_selected`.

- `character`: refers to the object name in `data`, for example

      .determine_delayed(data = iris, x = "Species")
      .determine_delayed(data = iris, x = c("Species", "inexisting"))
      .determine_delayed(data = list2env(list(iris = iris, mtcars = mtcars)), x = "iris")

- `quosure`: delayed (quoted) `tidyselect-helper` to be evaluated
  through
  [`tidyselect::eval_select`](https://tidyselect.r-lib.org/reference/eval_select.html).
  For example

      .determine_delayed(data = iris, x = rlang::quo(tidyselect::starts_with("Sepal")))
      .determine_delayed(data = iris, x = rlang::quo(1:2))
      .determine_delayed(data = iris, x = rlang::quo(Petal.Length:Sepal.Length))

- `function(x)`: predicate function returning a logical flag. Evaluated
  for each `data` element. For example


      .determine_delayed(data = iris, x = is.numeric)
      .determine_delayed(data = letters, x = function(x) x > "c")
      .determine_delayed(data = list2env(list(iris = iris, mtcars = mtcars, a = "a")), x = is.data.frame)
