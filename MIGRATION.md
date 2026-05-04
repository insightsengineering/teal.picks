# Migration from teal.transform to teal.picks

### Introduction

[`teal.picks`](https://github.com/insightsengineering/teal.picks) is a teal framework package for interactive dataset, column, and value selection in teal applications. It replaces `teal.transform` and extends its capabilities.

If you are developing a new teal app or module, prefer `teal.picks`. If you maintain existing code that still uses `teal.transform`, this guide provides a practical migration path to move safely and incrementally to `teal.picks`.

### Migration Headlines

The migration process can be divided into the following steps:

1. Replace module components that define which datasets, columns, and values are available.
2. Update the teal UI to use `teal.picks` components.
3. Update the teal server logic to extract, merge, and consume the processed data.

When implementing a migration, there are two main scenarios:

A. You maintain a teal app and want to migrate `teal.transform` components to `teal.picks`.
B. You maintain a set of teal modules or a teal modules package and want to add support for `teal.picks`.

The main difference is that in scenario A you remove `teal.transform` usage entirely, while in scenario B you keep backward compatibility so modules can work with both `teal.transform` and `teal.picks`.

With that said, we are going to go through the full migration process step by step (which will cover both migration scenarios) and finish with some notes on scenario B.

#### 1. Replacing selections on datasets, variables and values by `teal.picks` functions

To begin with a migration, the easiest way is to start with module arguments that define user selections. Before you start, make sure you are
familiar with `picks` [API](https://insightsengineering.github.io/teal.picks/). Then, take a look at your module and analyze which arguments are
`teal.transform` objects. Depending on the type of `teal.transform` data extract object, you will select one or another `teal.picks`
component to replace it.
There are some `teal.transform` objects that have a direct replacement in `teal.picks`. Others are not directly supported, therefore the required
refactor will be larger. Let's explore those equivalences when replacing `teal.transform` data extract constructors.

`teal.transform::choices_selected` -> `teal.picks::variables` or `teal.picks::values()`

The `choices_selected` constructor exposes which variables and values are available for user selection and, if provided, the default selection. In most cases, the variables are columns from a dataset and values are unique elements of a column. The following example shows how to replace it with `teal.picks`:

```
my_module <- function(
  arm_var = teal.transform::choices_selected( # teal.picks::variables specific choices
    choices = variable_choices(ADSL, subset = c("ARM", "ARMCD")),
    selected = "ARM"
  ),
  table_var = teal.transform::choices_selected( # teal.picks::variables tidyselect/function choices
    choices = variable_choices(ADSL),
    selected = "SEX"
  ),
  treatment_flag = teal.transform::choices_selected("Y"), # teal.picks::values
  dataname = "ADSL",
  ...
) {
  # module code
}

```

The migrated chunk would look as follows:

```
my_module <- function(
  arm_var = teal.picks::variables(choices = c("ARM", "ARMCD"), selected = "ARM"),
  table_var = teal.picks::variables(choices = tidyselect::everything(), selected = "SEX"),
  treatment_flag = teal.picks::values("Y"),
  dataname = "ADSL",
  ...
) {
  # module code
  arm_var <- teal.picks::picks(
    datasets(choices = dataname, selected = dataname),
    variables = arm_var
  )
  table_var <- teal.picks::picks(
    datasets(choices = dataname, selected = dataname),
    variables = table_var
  )
  # more code
}
```

Therefore, we can use `teal.picks::variables` to replace `choices_selected`, whether it sets specific or open selections. With `teal.picks`, we also have much more flexibility and control on selections with the possibility of using
`tidyselect` predicates or custom functions for the selection of variables and values (currently only functions allowed for values). Additionally, if the variables are columns from a dataset (the most common case), we can assign them
inside the module when creating the picks object from the dataset.

When `teal.transform::choices_selected` uses `teal.transform::value_choices` to define variables and values:

```
paramcd <- teal.transform::choices_selected(
  choices = teal.transform::value_choices(data[["ADQS"]], "PARAMCD", "PARAM"),
  selected = "FKSI-FWB"
)
```

We recommend replacing it directly with `teal.picks::picks` and `check_dataset = FALSE`:

```
all_values <- function(x) unique(x)
class(all_values) <- append(class(all_values), "des-delayed")

# module code
  ...,
  paramcd = teal.picks::picks(
    teal.picks::variables(choices = c("PARAMCD", "PARAM")),
    teal.picks::values(choices = all_values, selected = "FKSI-FWB"),
    check_dataset = FALSE
)
```
This lets us control both the available variables/values and the default selection. Later in the module function, we add the dataset that contains those
variables and values (code not shown).

`teal.transform::data_extract_spec` should be migrated to `teal.picks::picks`

`teal.transform::data_extract_spec` is a function that allows users to select and/or filter a dataset. Additionally, it creates a UI component together with `teal.transform::data_extract_ui`. The variables for column selection are set with `teal.transform::select_spec` and the values for data filtering with `teal.transform::filter_spec`. With `teal.picks`, it becomes simpler.

In the following example, we see `teal.transform::data_extract_spec` objects:

```
select_data_extract <- data_extract_spec(
  dataname = "ADSL",
  select = teal.transform::select_spec(choices = c("BMRKR1", "AGE"))
)

filter_data_extract <- data_extract_spec(
  dataname = "ADSL",
  filter = teal.transform::filter_spec(vars = "SEX", choices = c("F", "M"))
)
```

They could be replaced by `teal.picks::picks` as follows:

```
my_picks_1 <- teal.picks::picks(
  teal.picks::datasets("ADSL", "ADSL"),
  teal.picks::variables(choices = c("BMRKR1", "AGE"))
)
my_picks_2 <- teal.picks::picks(
  teal.picks::datasets("ADSL", "ADSL"),
  teal.picks::variables(choices = "SEX"),
  teal.picks::values(choices = c("F", "M"), selected = "M")
)
```
With `teal.picks` we can include more than one variable when we use `teal.picks::values` for filtering. In this case, the values used for filtering are the combined values across all selected variables.
In the case when a `teal.transform::data_extract_spec` has both `select_spec` and `filter_spec`:

```
simple_des <- teal.transform::data_extract_spec(
  dataname = "ADSL",
  filter = teal.transform::filter_spec(vars = "SEX", choices = c("F", "M")),
  select = teal.transform::select_spec(choices = c("BMRKR1", "AGE"))
)
```
It is better to create two separate picks, one for selecting columns and another for filtering through values. It would be possible to create a single picks with more than one variable and values, but then the filtering values would be the combined values from all selected variables. That behavior is different from `teal.transform::data_extract_spec`, where filtering is independent from column selection.

Now that we have all the data extraction functions from `teal.transform` we can explore how to modify the UI of our modules when migrating to `teal.picks`.

#### 2. `teal.picks` updates for UI

The second step in your migration is updating your UI layer. With `teal.picks`, UI code is usually simpler and more flexible.
The key function is `teal.picks::picks_ui`. This generic creates the appropriate UI control based on the `picks` object type. For example, when the user selects categorical values (such as variables), `teal.picks::picks_ui` creates a picker-like input.
In practice, there are different UI patterns in `teal.transform`, but in many cases they can be replaced with `teal.picks::picks_ui`. The two most common scenarios are:

1. Cases where a `teal.transform::choices_selected` object is consumed by a `teal.widgets` input function.
2. Calls to `teal.transform::data_extract_ui`

Let's start with scenario 1.

```
# in this case, args is a named list of module arguments, including all choices_selected
my_module_ui <- function(args, ...) {
  # ui code
  teal.widgets::optionalSelectInput(
    ns("right_var"),
    "Right Dichotomization Variable",
    args$right_var$choices,
    args$right_var$selected,
    multiple = FALSE
  )
}
```

It can be replaced as follows:

```
my_module_ui <- function(args, ...) {
  # ui code
  shiny::tags$div(
    shiny::tags$strong("Right Dichotomization Variable"),
    teal.picks::picks_ui(id = ns("right_var"), picks = args$right_var)
  )
}
```

`teal.picks::picks_ui` does not include a label, so adding a wrapper (for example `shiny::tags$div`) and a label element is a common pattern. Also, `teal.picks` handles `picks` arguments such as `multiple` and `fixed`, so those options usually do not need to be duplicated in the UI call.

The only scenario where `teal.picks::picks_ui` cannot be used is when you have a standalone `teal.picks::values()` object (not wrapped inside a `picks` object). In that case, use a regular UI control from `shiny`, `teal.widgets`, or another UI library.

For example, if this is the `teal.picks::values` object:

```
count_by_var <- teal.picks::values(
  selected = "# of patients",
  choices = c("# of patients", "# of AEs")
)
```

Then create the UI explicitly:

```
shiny::radioButtons(
  ns("count_by_var"),
  "Count By Variable",
  count_by_var$choices,
  count_by_var$selected
)
```

Now let's move to `teal.transform::data_extract_ui` scenario.

In general, `teal.transform::data_extract_ui` should be migrated to `teal.picks::picks_ui` calls. However, because `teal.transform::data_extract_spec` does not always map one-to-one to a single `teal.picks` object, first identify whether your old UI is simple or complex.

Simple case: one `data_extract_spec` with only a `select_spec` or only a `filter_spec`. This typically maps to one `teal.picks::picks_ui`.

Complex case: a `data_extract_spec` containing both `select_spec` and `filter_spec`, or a `data_extract_ui` built from a list of `data_extract_spec` objects. This usually maps to multiple `teal.picks::picks_ui` components.

Simple conversion example (`teal.transform::data_extract_ui` -> `teal.picks::picks_ui`):
```
spec_vars <- teal.transform::data_extract_spec(
  dataname = "ADSL",
  select = teal.transform::select_spec(choices = c("AGE", "SEX"))
)

my_module_ui <- function(id, ...) {
  ns <- shiny::NS(id)
  teal.transform::data_extract_ui(id = ns("vars"), data_extract = spec_vars)
}
```

And after migration

```
vars_picks <- teal.picks::picks(
  teal.picks::datasets("ADSL", "ADSL"),
  teal.picks::variables(choices = c("AGE", "SEX"))
)

my_module_ui <- function(id, ...) {
  ns <- shiny::NS(id)
  shiny::tags$div(
    shiny::tags$strong("Variables"),
    teal.picks::picks_ui(id = ns("vars"), picks = vars_picks)
  )
}
```

Now let's see a complex conversion example (`teal.transform::data_extract_ui` with multiple specs):

```
adsl_spec <- teal.transform::data_extract_spec(
  dataname = "ADSL",
  select = teal.transform::select_spec(choices = c("AGE", "BMRKR1", "SEX")),
  filter = teal.transform::filter_spec(vars = "SEX", choices = c("F", "M"))
)

adae_spec <- teal.transform::data_extract_spec(
  dataname = "ADAE",
  select = teal.transform::select_spec(choices = c("AETERM", "AESER")),
  filter = teal.transform::filter_spec(vars = "AESER", choices = c("Y", "N"))
)

my_module_ui <- function(id) {
  ns <- shiny::NS(id)
  teal.transform::data_extract_ui(
    id = ns("extracts"),
    data_extract = list(adsl_spec, adae_spec)
  )
}
```

This is how it could be migrated to keep selection and filtering as separate picks to preserve old behavior:

```
adsl_select_picks <- teal.picks::picks(
  teal.picks::datasets("ADSL", "ADSL"),
  teal.picks::variables(choices = c("AGE", "BMRKR1", "SEX"))
)

adsl_filter_picks <- teal.picks::picks(
  teal.picks::datasets("ADSL", "ADSL"),
  teal.picks::variables(choices = "SEX"),
  teal.picks::values(choices = c("F", "M"))
)

adae_select_picks <- teal.picks::picks(
  teal.picks::datasets("ADAE", "ADAE"),
  teal.picks::variables(choices = c("AETERM", "AESER"))
)

adae_filter_picks <- teal.picks::picks(
  teal.picks::datasets("ADAE", "ADAE"),
  teal.picks::variables(choices = "AESER"),
  teal.picks::values(choices = c("Y", "N"))
)

my_module_ui <- function(id, ...) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::tags$h4("ADSL"),
    shiny::tags$div(
      shiny::tags$strong("ADSL variables"),
      teal.picks::picks_ui(id = ns("adsl_vars"), picks = adsl_select_picks)
    ),
    shiny::tags$div(
      shiny::tags$strong("ADSL filter"),
      teal.picks::picks_ui(id = ns("adsl_filter"), picks = adsl_filter_picks)
    ),
    shiny::tags$h4("ADAE"),
    shiny::tags$div(
      shiny::tags$strong("ADAE variables"),
      teal.picks::picks_ui(id = ns("adae_vars"), picks = adae_select_picks)
    ),
    shiny::tags$div(
      shiny::tags$strong("ADAE filter"),
      teal.picks::picks_ui(id = ns("adae_filter"), picks = adae_filter_picks)
    )
  )
}
```

#### 3. `teal.picks` updates for server-side merge (`data_merge`)

After migrating selection objects and UI, update the server-side merge logic.

In `teal.transform`, modules often use `merge_*` helper functions to resolve selections, merge datasets, and expose selected variables/values to downstream reactives. In `teal.picks`, the equivalent flow is:

1. Build a named list of `picks` objects used by the module.
2. Initialize selectors with `teal.picks::picks_srv`.
3. Merge with `teal.picks::merge_srv`.


Now let's show a module-style example with two `picks` arguments, `arm_var` and `table_var`.

Previously the code could be like this:

```
moduleServer(id, function(input, output, session) {
  # access selectors
  selector_list <- teal.transform::data_extract_multiple_srv(
    data_extract = list(
      arm_var = arm_var,
      table_var = table_var
    ),
    datasets = data,
    select_validation_rule = list(
    # validations here
    ),
    filter_validation_rule = list(
    # filter validations here
    )
  )

  # access merged datasets
  anl_inputs <- teal.transform::merge_expression_srv(
    datasets = data,
    selector_list = selector_list,
    merge_function = "dplyr::inner_join",
    data = data
  )

  # create a qenv for reproducible code operations with merged data
  anl_q <- reactive({
    data() |>
      ...
    # add operations here
  })
   
})
```
This code was used to access selectors and perform input validation. It also provided access to merged datasets for downstream operations.
With `teal.picks` it becomes much simpler. First we declare the list of selectors with `teal.picks::picks_srv`:
```
my_module_srv <- function(id, data, arm_var, table_var) {
  moduleServer(id, function(input, output, session) {

    picks_list <- list(
      arm_var = arm_var,
      table_var = table_var
    )

    selectors <- teal.picks::picks_srv(
      picks = picks_list,
      data = data
    )

  })
}

```
Data validation can be performed directly with `shiny::validate/need` or any other form of validation, we can access inputs:

```
validations <- shiny::reactive({
  input_arm_var <- selectors$arm_var()$variables$selected
  shiny::validate(shiny::need(
    length(input_arm_var) >= 1L,
    "Please select a arm_var variable."
    ))
})

```

Finally, we can access the merged datasets and use them to create outputs.

```
merged <- teal.picks::merge_srv(
      "merge",
      data = data,
      selectors = selectors,
      output_name = "anl"
    )

output$table <- shiny::renderTable({
  validations()

  data <- merged$data()
  arm <- selectors$arm_var()$variables$selected
  cols <- selectors$table_var()$variables$selected

  data[["anl"]][, unique(c(arm, cols)), drop = FALSE]
})
```

Here we covered a small example. There are many possibilities with downstream objects exposed by `selectors` and `merged`.


#### 4. Notes on maintaining support for `teal.picks` and `teal.transform`

If you need to maintain support for both `teal.transform` and `teal.picks` arguments (for example, in a reusable `teal` module), there are strategies that can simplify the migration.

`teal.picks::as.picks` converts supported `teal.transform` objects to `teal.picks::picks`. See `help(teal.picks::as.picks)` for the exact list of supported `teal.transform` constructors.

Therefore, if your module contains only arguments that can be converted with `teal.picks::as.picks`, you can support both packages as follows:

1. Modify your module function so it accepts both `teal.picks` and `teal.transform` arguments.
2. If the module is called with `teal.transform` objects, convert them to `teal.picks` by calling `as.picks`.
3. Migrate your module, UI, and server functions as described in sections 1, 2, and 3. After conversion, the rest of the implementation can rely on `teal.picks` only.

If your module uses `teal.transform` objects that are not supported by `teal.picks::as.picks`, maintain full dual support (for example, separate module/UI/server paths or explicit compatibility wrappers) until those inputs can be fully migrated.