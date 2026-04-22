# Choices/selected settings

Define choices and default selection for variables. `picks` allows
app-developer to specify `datasets`, `variables` and `values` to be
selected by app-user during Shiny session. Functions are based on the
idea of `choices/selected` where app-developer provides `choices` and
what is `selected` by default. App-user changes `selected` interactively
(see
[`picks_module`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)).

## Usage

``` r
picks(..., check_dataset = TRUE)

datasets(choices = tidyselect::everything(), selected = 1L, fixed = NULL, ...)

variables(
  choices = tidyselect::everything(),
  selected = 1L,
  multiple = NULL,
  fixed = NULL,
  ordered = FALSE,
  ...
)

values(
  choices = function(x) !is.na(x),
  selected = function(x) !is.na(x),
  multiple = TRUE,
  fixed = NULL,
  ...
)
```

## Arguments

- ...:

  for `picks(...)`: hierarchical structure that contains `datasets()` as
  first element and optionally `variables()` and `values()`

  for `variables(...)` and `values(...)`: additional arguments delivered
  to `pickerInput`

- choices:

  ([`tidyselect::language`](https://tidyselect.r-lib.org/reference/language.html)
  or `character`) Available values to choose.

- selected:

  ([`tidyselect::language`](https://tidyselect.r-lib.org/reference/language.html)
  or `character`) Choices to be selected.

- fixed:

  (`logical(1)`) selection will be fixed and not possible to change
  interactively.

- multiple:

  (`logical(1)`) if more than one selection is possible.

- ordered:

  (`logical(1)`) if the selected should follow the selection order. If
  `FALSE` `selected` returned from `srv_module_input()` would be ordered
  according to order in `choices`.

- dataset_check::

  (`logical(1)`) whether to check that the first element of `picks` is
  `datasets()`. This is useful to set to `FALSE` when creating picks
  objects that have a required dataset that is not selected by the user
  and defined in the module itself.

## `tidyselect` support

Both `choices` and `selected` parameters support `tidyselect` syntax,
enabling dynamic and flexible variable selection patterns. This allows
choices to be determined at runtime based on data characteristics rather
than hard-coded values.

### Using `tidyselect` for `choices` and `selected`

When `choices` uses `tidyselect`, the available options are determined
dynamically based on actually selected data:

- [`tidyselect::everything()`](https://tidyselect.r-lib.org/reference/everything.html) -
  All variables/datasets

- `tidyselect::starts_with("prefix")` - Variables starting with a prefix

- `tidyselect::ends_with("suffix")` - Variables ending with a suffix

- `tidyselect::contains("pattern")` - Variables containing a pattern

- `tidyselect::matches("regex")` - Variables matching a regular
  expression

- `tidyselect::where(predicate)` - Variables/datasets satisfying a
  predicate function

- `tidyselect::all_of(vars)` - All specified variables (error if
  missing)

- `tidyselect::any_of(vars)` - Any specified variables (silent if
  missing)

- Range selectors like `Sepal.Length:Petal.Width` - Variables between
  two positions

- Integer indices (e.g., `1L`, `1L:3L`, `c(1L, 3L, 5L)`) - Select by
  position. Be careful, must be integer!

The `selected` parameter can use the same syntax but it will be applied
to the subset defined in choices. This means that
`choices = is.numeric, selected = is.factor` or
`choices = c("a", "b", "c"), selected = c("d", "e")` will imply en empty
`selected`.

**Warning:** Using explicit character values for `selected` with dynamic
`choices` may cause issues if the selected values are not present in the
dynamically determined choices. Prefer using numeric indices (e.g., `1`
for first variable) when `choices` is dynamic.

## Structure and element dependencies

The `picks()` function creates a hierarchical structure where elements
depend on their predecessors, enabling cascading reactive updates during
Shiny sessions.

### Element hierarchy

A `picks` object must follow this order:

1.  **`datasets()`** - to select a dataset. Always the first element
    (required).

2.  **`variables()`** - To select columns from the chosen dataset.

3.  **`values()`** - To select specific values from the chosen
    variable(s).

Each element's choices are evaluated within the context of its
predecessor's selection.

### How dependencies work

- **Fixed dataset**: When `datasets(choices = "iris")` specifies one
  dataset, the `variables()` choices are evaluated against that dataset
  columns.

- **Multiple dataset choices**: When
  `datasets(choices = c("iris", "mtcars"))` allows multiple options,
  `variables()` choices are re-evaluated each time the user selects a
  different dataset. This creates a reactive dependency where variable
  choices update automatically.

- **Dynamic dataset choices**: When using
  `datasets(choices = tidyselect::where(is.data.frame))`, all available
  data frames are discovered at runtime, and variable choices adapt to
  whichever dataset the user selects.

- **Variable to values**: Similarly, `values()` choices are evaluated
  based on the selected variable(s), allowing users to filter specific
  levels or values. When multiple variables are selected, then values
  will be a concatenation of the columns.

### Best practices

- Always start with `datasets()` - this is enforced by validation

- Use dynamic `choices` in `variables()` when working with multiple
  datasets to ensure compatibility across different data structures

- Prefer
  [`tidyselect::everything()`](https://tidyselect.r-lib.org/reference/everything.html)
  or
  [`tidyselect::where()`](https://tidyselect.r-lib.org/reference/where.html)
  predicates for flexible variable selection that works across datasets
  with different schemas

- Use numeric indices for `selected` when `choices` are dynamic to avoid
  referencing variables that may not exist in all datasets

### Important: `values()` requires type-aware configuration

#### Why `values()` is different from `datasets()` and `variables()`

`datasets()` and `variables()` operate on named lists of objects,
meaning they work with character-based identifiers. This allows you to
use text-based selectors like `starts_with("S")` or `contains("prefix")`
consistently for both datasets and variable names.

`values()` is fundamentally different because it operates on the
**actual data content** within a selected variable (column). The type of
data in the column determines what kind of filtering makes sense:

- **`numeric` columns** (e.g., `age`, `height`, `price`) contain numbers

- **`character`/`factor` columns** (e.g., `country`, `category`,
  `status`) contain categorical values

- **`Date`/`POSIXct` columns** contain temporal data

- **`logical` columns** contain TRUE/FALSE values

#### Type-specific UI controls

The `values()` function automatically renders different UI controls
based on data type:

- **`numeric` data**: Creates a `sliderInput` for range selection

  - `choices` must be a numeric vector of length 2: `c(min, max)`

  - `selected` must be a numeric vector of length 2:
    `c(selected_min, selected_max)`

- **Categorical data** (`character`/`factor`): Creates a `pickerInput`
  for discrete selection

  - `choices` can be a character vector or predicate function

  - `selected` can be specific values or a predicate function

- **`Date`/`POSIXct` data**: Creates date/datetime range selectors

  - `choices` must be a Date or `POSIXct` vector of length 2

- **`logical` data**: Creates a checkbox or picker for TRUE/FALSE
  selection

#### Developer responsibility

**App developers must ensure `values()` configuration matches the
variable type:**

1.  **Know your data**: Understand what type of variable(s) users might
    select

2.  **Configure appropriately**: Set `choices` and `selected` to match
    expected data types

3.  **Use predicates for flexibility**: When variable type is dynamic,
    use predicate functions like `function(x) !is.na(x)` (the default)
    to handle multiple types safely

#### Examples of correct usage

    # For a numeric variable (e.g., age)
    picks(
      datasets(choices = "demographic"),
      variables(choices = "age", multiple = FALSE),
      values(choices = c(0, 100), selected = c(18, 65))
    )

    # For a categorical variable (e.g., country)
    picks(
      datasets(choices = "demographic"),
      variables(choices = "country", multiple = FALSE),
      values(choices = c("USA", "Canada", "Mexico"), selected = "USA")
    )

    # Safe approach when variable type is unknown - use predicates
    picks(
      datasets(choices = "demographic"),
      variables(choices = tidyselect::everything(), selected = 1L),
      values(choices = function(x) !is.na(x), selected = function(x) !is.na(x))
    )

#### Common mistakes to avoid

    # WRONG: Using string selectors for numeric data
    values(choices = starts_with("5"))  # Doesn't make sense for numeric data!

    # WRONG: Providing categorical choices for a numeric variable
    values(choices = c("low", "medium", "high"))  # Won't work if variable is numeric!

    # WRONG: Providing numeric range for categorical variable
    values(choices = c(0, 100))  # Won't work if variable is factor/character!

### Example: Three-level hierarchy

    picks(
      datasets(choices = c("iris", "mtcars"), selected = "iris"),
      variables(choices = tidyselect::where(is.numeric), selected = 1L),
      values(choices = tidyselect::everything(), selected = seq_len(10))
    )

In this example:

- User first selects a dataset (`iris` or `mtcars`)

- Variable choices update to show only numeric columns from selected
  dataset

- After selecting a variable, value choices show all unique values from
  that column

## Examples

``` r
# Select columns from iris dataset using range selector
picks(
  datasets(choices = "iris"),
  variables(choices = Sepal.Length:Petal.Width, selected = 1L)
)
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: Sepal.Length:Petal.Width
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Single variable selection from iris dataset
picks(
  datasets(choices = "iris", selected = "iris"),
  variables(choices = c("Sepal.Length", "Sepal.Width"), selected = "Sepal.Length", multiple = FALSE)
)
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: iris
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: Sepal.Length, Sepal.Width
#>      selected: Sepal.Length
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Dynamic selection: any variable from iris, first selected by default
picks(
  datasets(choices = "iris", selected = "iris"),
  variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
)
#>  <picks>
#>    <datasets>:
#>      choices: iris
#>      selected: iris
#>      multiple=FALSE, ordered=FALSE, fixed=TRUE
#>    <variables>:
#>      choices: tidyselect::everything()
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Multiple dataset choices: variable choices will update when dataset changes
picks(
  datasets(choices = c("iris", "mtcars"), selected = "iris"),
  variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
)
#>  <picks>
#>    <datasets>:
#>      choices: iris, mtcars
#>      selected: iris
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: tidyselect::everything()
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Select from any dataset, filter by numeric variables
picks(
  datasets(choices = c("iris", "mtcars"), selected = 1L),
  variables(choices = tidyselect::where(is.numeric), selected = 1L)
)
#>  <picks>
#>    <datasets>:
#>      choices: iris, mtcars
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: <fn>
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Fully dynamic: auto-discover datasets and variables
picks(
  datasets(choices = tidyselect::where(is.data.frame), selected = 1L),
  variables(choices = tidyselect::everything(), selected = 1L, multiple = FALSE)
)
#>  <picks>
#>    <datasets>:
#>      choices: <fn>
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: tidyselect::everything()
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE

# Select categorical variables with length constraints
picks(
  datasets(choices = tidyselect::everything(), selected = 1L),
  variables(choices = is_categorical(min.len = 2, max.len = 15), selected = seq_len(2))
)
#>  <picks>
#>    <datasets>:
#>      choices: tidyselect::everything()
#>      selected: 1L
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE
#>    <variables>:
#>      choices: <fn>
#>      selected: <int>
#>      multiple=FALSE, ordered=FALSE, fixed=FALSE, allow-clear=FALSE
```
