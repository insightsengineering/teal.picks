# Merge Server Function for Dataset Integration

`merge_srv` is a powerful Shiny server function that orchestrates the
merging of multiple datasets based on user selections from `picks`
objects. It creates a reactive merged dataset (`teal_data` object) and
tracks which variables from each selector are included in the final
merged output.

This function serves as the bridge between user interface selections
(managed by selectors) and the actual data merging logic. It
automatically handles:

- Dataset joining based on join keys

- Variable selection and renaming to avoid conflicts

- Reactive updates when user selections change

- Generation of reproducible R code for the merge operation

## Usage

``` r
merge_srv(
  id,
  data,
  selectors,
  output_name = "anl",
  join_fun = "dplyr::inner_join"
)
```

## Arguments

- id:

  (`character(1)`) Module ID for the Shiny module namespace

- data:

  (`reactive`) A reactive expression returning a
  [teal.data::teal_data](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
  object containing the source datasets to be merged. This object must
  have join keys defined via
  [`teal.data::join_keys()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)
  to enable proper dataset relationships.

- selectors:

  (`named list`) A named list of selector objects. Each element can be:

  - A `picks` object defining dataset and variable selections

  - A `reactive` expression returning a `picks` object The names of this
    list are used as identifiers for tracking which variables come from
    which selector.

- output_name:

  (`character(1)`) Name of the merged dataset that will be created in
  the returned `teal_data` object. Default is `"anl"`. This name will be
  used in the generated R code.

- join_fun:

  (`character(1)`) The joining function to use for merging datasets.
  Must be a qualified function name (e.g., `"dplyr::left_join"`,
  `"dplyr::inner_join"`, `"dplyr::full_join"`). Default is
  `"dplyr::inner_join"`. The function must accept `by` and `suffix`
  parameters.

## Value

A `list` with two reactive elements:

- `data`A `reactive` returning a
  [teal.data::teal_data](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
  object containing the merged dataset. The merged dataset is named
  according to `output_name` parameter. The `teal_data` object includes:

  - The merged dataset with all selected variables

  - Complete R code to reproduce the merge operation

  - Updated join keys reflecting the merged dataset structure

- `variables` A `reactive` returning a named list mapping selector names
  to their selected variables in the merged dataset. The structure is:
  `list(selector_name_1 = c("var1", "var2"), selector_name_2 = c("var3", "var4"), ...)`.
  Variable names reflect any renaming that occurred during the merge to
  avoid conflicts.

## How It Works

The `merge_srv` function performs the following steps:

1.  **Receives Input Data**: Takes a reactive `teal_data` object
    containing source datasets with defined join keys

2.  **Processes Selectors**: Evaluates each selector (whether static
    `picks` or reactive) to determine which datasets and variables are
    selected

3.  **Determines Merge Order**: Uses topological sort based on the
    `join_keys` to determine the optimal order for merging datasets.

4.  **Handles Variable Conflicts**: Automatically renames variables
    when:

    - Multiple selectors choose variables with the same name from
      different datasets

    - Foreign key variables would conflict with existing variables

    - Renaming follows the pattern `{column-name}_{dataset-name}`

5.  **Performs Merge**: Generates and executes merge code that:

    - Selects only required variables from each dataset

    - Applies any filters defined in selectors

    - Joins datasets using specified join function and join keys

    - Maintains reproducibility through generated R code

6.  **Updates Join Keys**: Creates new join key relationships for the
    merged dataset (`"anl"`) relative to remaining datasets in the
    `teal_data` object

7.  **Tracks Variables**: Keeps track of the variable names in the
    merged dataset

## Usage Pattern

    # In your Shiny server function
    merged <- merge_srv(
      id = "merge",
      data = shiny::reactive(my_teal_data),
      selectors = list(
        selector1 = picks(...),
        selector2 = shiny::reactive(picks(...))
      ),
      output_name = "anl",
      join_fun = "dplyr::left_join"
    )

    # Access merged data
    merged_data <- merged$data()  # teal_data object with merged dataset
    anl <- merged_data[["anl"]]   # The actual merged data.frame/tibble

    # Get variable mapping
    vars <- merged$variables()
    # Returns: list(selector1 = c("VAR1", "VAR2"), selector2 = c("VAR3", "VAR4_ADSL"))

    # Get reproducible code
    code <- teal.code::get_code(merged_data)

## Merge Logic Details

**Dataset Order**: Datasets are merged in topological order based on
join keys. The first dataset acts as the "left" side of the join, and
subsequent datasets are joined one by one.

**Join Keys**: The function uses join keys from the source `teal_data`
object to determine:

- Which datasets can be joined together

- Which columns to use for joining (the `by` parameter)

- Whether datasets need intermediate joins (not yet implemented)

**Variable Selection**: For each dataset being merged:

- Selects user-chosen variables from selectors

- Includes foreign key variables needed for joining (even if not
  explicitly selected)

- Removes duplicate foreign keys after join (they're already in the left
  dataset)

**Conflict Resolution**: When variable names conflict:

- Variables from later datasets get suffixed with `_dataname`

- Foreign keys that match are merged (not duplicated)

- The mapping returned in `merge_vars` reflects the final names

## Integration with Selectors

`merge_srv` is designed to work with
[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
which creates selector objects:

    # Create selectors in server
    selectors <- picks_srv(
      picks =  list(
        adsl = picks(...),
        adae = picks(...)
      ),
      data = data
    )

    # Pass to merge_srv
    merged <- merge_srv(
      id = "merge",
      data = data,
      selectors = selectors
    )

## See also

- [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  for creating selectors

- [`teal.data::join_keys()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)
  for defining dataset relationships

## Examples

``` r
# Complete example with CDISC data
library(teal.picks)
library(teal.data)
#> Loading required package: teal.code
library(shiny)

# Prepare data with join keys
data <- teal_data()
data <- within(data, {
  ADSL <- teal.data::rADSL
  ADAE <- teal.data::rADAE
})
join_keys(data) <- default_cdisc_join_keys[c("ADSL", "ADAE")]

# Create Shiny app
ui <- fluidPage(
  picks_ui("adsl", picks(datasets("ADSL"), variables())),
  picks_ui("adae", picks(datasets("ADAE"), variables())),
  verbatimTextOutput("code"),
  verbatimTextOutput("vars")
)

server <- function(input, output, session) {
  # Create selectors
  selectors <- list(
    adsl = picks_srv("adsl",
      data = shiny::reactive(data),
      picks = picks(datasets("ADSL"), variables())
    ),
    adae = picks_srv("adae",
      data = shiny::reactive(data),
      picks = picks(datasets("ADAE"), variables())
    )
  )

  # Merge datasets
  merged <- merge_srv(
    id = "merge",
    data = shiny::reactive(data),
    selectors = selectors,
    output_name = "anl",
    join_fun = "dplyr::left_join"
  )

  # Display results
  output$code <- renderPrint({
    cat(teal.code::get_code(merged$data()))
  })

  output$vars <- renderPrint({
    merged$variables()
  })
}
if (interactive()) {
  shinyApp(ui, server)
}
```
