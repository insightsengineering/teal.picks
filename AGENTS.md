
# teal.picks R Package Development Guide

## Package Overview

`teal.picks` is part of the `teal` framework and provides the dataset,
variable and value pickers used in `teal` modules. It lets `teal` app
developers declare which dataset, columns and values the app user can
choose, renders the matching inputs, and merges the selected data into
an analysis-ready `teal_data` object with reproducible code.

## Development Context

It provides 3 main features to the framework:

- `picks` specification (`R/picks.R`): S3 objects that define `choices`
  and default `selected` for a hierarchy of selections
  - `picks()` is a list of `pick` objects named after their class:
    `datasets()` first, followed by `variables()` and then `values()`
  - a `pick` is `list(choices, selected)` with `multiple`, `fixed`,
    `ordered` and extra `pickerInput` options stored as attributes
  - `choices`/`selected` could be:
    - eager: `character` names, or plain values for `values()`
    - `tidyselect` expressions, quoted with `rlang::enquo()`; integer
      positions such as the default `selected = 1L` count as
      `tidyselect`
    - predicate functions, e.g. `is.numeric`; the only delayed form
      accepted by `values()`
- Shiny modules `picks_ui()`/`picks_srv()` render one input per `pick`,
  by default, and return a `reactiveVal` (`picks_resolved`) with the
  resolved `picks`
- Merging function `merge_srv()` merges the selected data into one
  dataset (`anl` by default) and returns the merged `teal_data` and the
  selected variables

See `vignettes/teal-picks-in-teal.Rmd` for usage in `teal` modules and
`vignettes/teal-picks-standalone-shiny.Rmd` for standalone `shiny`
usage.

### Resolution of `picks`

- `resolver()` walks the `picks` in order: the `determine()` S3 generic
  resolves `choices` and then `selected` of each element and passes the
  selected data to the next one (`teal_data` → dataset → selected
  columns).
- Names given as text are matched against the data and unknown ones are
  dropped silently (a warning appears only if none match):
  `variables(c("AGE", "SEXX"))` offers only `AGE`.
- `values()` are resolved against the unique values of the selected
  columns. Functions with class `"des-delayed"` are called once with all
  the data instead of per element.
- Range inputs are created only when `values()` uses `ranged()` (class
  `"ranged"`); eager numeric vectors are matched as discrete values.
- If an element ends up with nothing selected, every element after it is
  emptied (`choices` and `selected` become `NULL`).

### Reactive flow in `picks_srv()`

- Changing the dataset resets `variables()` and `values()` to their
  defaults, and changing the variables resets `values()` (`.resolve()`).
- Categorical inputs (`shinyWidgets::pickerInput()`) commit only when
  the drop-down closes (`input$<element>-selected_open` becomes
  `FALSE`).
- Inputs are rendered again only when `choices` change
  (`bindEvent(choices())`); updating `picks_resolved` alone doesn’t
  update the input.

### Merge code generation

- `.merge_summary_list()` checks the selections and `join_keys`, merges
  parents first (e.g., `ADSL` before `ADAE`), renames duplicated columns
  (`AGE_ADAE`) and sets the `join_keys` of `anl`.
- `.merge_expr()` writes the merge code: `dplyr::select()` (keys always
  kept), `dplyr::filter()` only if `values()` drop rows, then `join_fun`
  for each extra dataset, chained with `%>%`.

### Relationships with other packages

Direct dependencies:

- `teal.data`: `teal_data` and `join_keys`.
  - Any issue with `join_keys` should be addressed in `teal.data`.
- `teal.code`: reproducible code (`eval_code()`, `get_code()`).
- `teal`: `tm_merge()` and `teal_transform_filter()` build
  `teal::module()`/`teal::teal_transform_module()` objects.
- `tidyselect`: dynamic `choices`/`selected`.
- `teal.transform` is in `Suggests`; `as.picks()` converts
  `data_extract_spec`/`select_spec`/`filter_spec` to `picks` to ease the
  transition away from `teal.transform`.

Usage in other framework packages:

- Module packages (`teal.modules.general`, `teal.modules.clinical`,
  `teal.modules.gtsummary`, `teal.goshawk`) take `picks` as module
  arguments, show them with `picks_ui()`, read the user’s choice with
  `picks_srv()` and build `anl` with `merge_srv()`.
  - `teal.modules.general` is migrating from `teal.transform`: the
    `picks` version of each module is in a `tm_*_picks.R` file next to
    the old `data_extract_spec` version.

### Workflows

- Bugs seen here may start in another package listed in the “Direct
  dependencies” section above.
- Changing exported functions can break module packages: they call
  `picks()`, `picks_srv()` and `merge_srv()` in their modules and the
  `app_driver_*()` helpers in their `shinytest2` tests.

### Testing

- In `testServer()`, apply a selection with
  `session$setInputs("variables-selected" = "AGE", "variables-selected_open" = FALSE)`,
  then check `picks_resolved()`. The input’s HTML is in
  `session$output[["variables-selected_container"]]$html`.
- In `shinytest2`, Shiny can’t see badge inputs until the badge is
  opened. Use `app_driver_get_teal_picks_slot()` and
  `app_driver_set_teal_picks_slot()`.

### Debugging tips

- Check resolution without an app: `print(resolver(picks, data))`.
  `data` can be a `teal_data`, an environment or a named list.
- Errors in `choices`/`selected` functions or `tidyselect` are hidden:
  - Symptom: an empty picker and the warning “None of the
    `choices/selected` … Emptying choices…”.
  - To see the error, run it on the data:
    `tidyselect::eval_select(rlang::quo(c(Species, Sepal.Lenght)), iris)`.
  - One unknown column empties the whole selection; use
    `tidyselect::any_of()` for optional columns.
- `no applicable method for 'join_keys<-' ... 'qenv.error'` means the
  merge code failed:
  - To see the real error, run
    `teal.code::eval_code(data, .merge_expr(.merge_summary_list(selectors, teal.data::join_keys(data), "anl"), "anl", join_fun, data))`,
    with `selectors` a named list of resolved `picks`.
  - Common cause: `%>%` is not available. Run `library(dplyr)` in the
    `teal_data` first; `devtools::load_all()` hides this because it
    attaches `testthat`, which exports `%>%`.
  - Common cause: a column is missing from a newly selected dataset
    (#56).
- Debug logs:
  `logger::log_threshold("DEBUG", namespace = "teal.picks")`, or
  `TEAL.LOG_LEVEL=DEBUG` before loading.

<!-- markdownlint-disable-file MD002 MD041 -->

This package is part of the teal framework. The following configuration
applies to all packages within the teal framework.

## Package Structure and Organization

### Key Directories

Follow the standard R package structure with teal-specific conventions:

``` text
package_name/
├── .github           # CI/CD workflows
├── R/                # R source code
├── tests/testthat/   # Unit tests using testthat
├── vignettes/        # Long-form documentation
├── inst/             # Package assets
├── AGENTS.md         # Development guide for AI agents (this file)
├── DESCRIPTION       # Package metadata
├── NAMESPACE         # Exports and imports
├── NEWS.md           # Change log
├── README.md         # Package overview
├── _pkgdown.yml      # Documentation website config
├── .lintr            # Linting configuration
└── .Rbuildignore     # Build exclusions
```

### Naming Conventions

- **Function names**: Use `snake_case` consistently
- **Class names**: Use `PascalCase` (e.g., `TealAppDriver`)
- **Module functions**: Prefix UI functions with `ui_` and server
  functions with `srv_`
- **Internal functions**: Use descriptive names without export

### File Organization

- **One main function per file** when the function is substantial
- **Group related utilities** in shared files (e.g., `utils.R`,
  `validations.R`)
- **Module files**: Use pattern `tm_<name>.R` for teal modules
- **Helper functions**: Prefix with the main function they support

## Code Style and Standards

### Code Quality

- **Run `pre-commit` hooks**: Always run `pre-commit run --all-files`
  before committing, Fix any issues it reports - the error messages are
  informative and will guide you. It automatically checks code style,
  documentation and other quality issues. If pre-commit is not
  available, run the checks manually. Lint the R code manually as well
  if not called by pre-commit.
- **Follow `tidyverse` style**: General R code style follows the
  `tidyverse` style guide.
- **Documentation**: All exported functions must have `roxygen2`
  documentation with `@returns` and `@examples` fields.
- **Formatting** rules are configured in the `.lintr` file.

## Dependencies and Imports

### Dependency Management

- **Minimize dependencies**: Only add dependencies that provide
  significant value
- **Version constraints**: Specify minimum versions for critical
  dependencies
- **Ecosystem coherence**: Prefer packages already used within teal
  ecosystem

### Import Best Practices

Avoid importing package functions via roxygen2 (`#' @import pkg`)tags in
favor of explicit namespacing for clarity when appropriate. When needed
prefer specific imports over full package imports.

<!-- Begins Module Section -->

## Modules Development

### Module features

Each module should produce one or more Table, Listing, or Graph (TLG):

- **Reproducibility**: All code being executed to generate TLGs should
  be run using `teal_data` and `within()` / `teal.code::eval_code()`
  - At the end of the module this object should be returned to enable
    Reporter and “Show R code” functionalities
- **User Parameters**: Configurable inputs via `teal.picks::picks()` for
  flexible data selection
- **Transformators**: Optional pre-processing functions that derive
  variables and validate data before analysis
- **Decorators**: Optional post-processing functions that customize
  output presentation (titles, legends, annotations)

### Module Architecture

Teal modules follow a specific pattern with UI and server components:

``` r
# UI Function
ui_example_module <- function(id, var_x, var_y, decorators) {
  ns <- shiny::NS(id)
  select_decorators <- getFromNamespace("select_decorators", "teal") # import from teal internal functions

  shiny::tagList(
    # Input controls
    teal.widgets::standard_layout(
      # Output displays
      output = teal.widgets::white_small_well(
        teal::ui_transform_teal_data("decorator_table", select_decorators(decorators, "plot")),
        teal::ui_transform_teal_data("decorator_table", select_decorators(decorators, "table")),
        shiny::tags$h4("Results"),
        shiny::plotOutput(ns("plot")),
        shiny::tags$h4("Summary data"),
        gt::gt_output(ns("table"))
      ),
      # Encoding panel
      encoding = shiny::tags$div(
        shiny::tags$label("Encodings", class = "text-primary"),
        shiny::tags$br(),
        shiny::tags$div(
          shiny::tags$strong("Select X-Axis Variable"),
          teal.picks::picks_ui(ns("var_x"), var_x)
        ),
        shiny::tags$div(
          shiny::tags$strong("Select Y-Axis Variable"),
          teal.picks::picks_ui(ns("var_y"), var_y)
        )
      )
    )
  )
}

# Server Function
srv_example_module <- function(id, data, var_x, var_y, decorators) {
  checkmate::assert_string(id)
  checkmate::assert_class(data, "reactive")

  select_decorators <- getFromNamespace("select_decorators", "teal") # import from teal internal functions
  shiny::moduleServer(id, function(input, output, session) {
    selectors <- teal.picks::picks_srv("picks", picks = list(var_x = var_x, var_y = var_y), data = data)
    merged <- teal.picks::merge_srv(
      "merge_picks",
      data = data,
      selectors = selectors,
      output_name = "anl",
      join_fun = "dplyr::inner_join"
    )
    # Data preparation
    validated_q <- shiny::reactive({
      shiny::validate(
        teal::need_input(
          inputId = "var_x-variables-selected",
          condition = length(selectors$var_x()$variables$selected) > 0,
          message = "X-Axis Variable must be selected"
        ),
        teal::need_input(
          inputId = "var_y-variables-selected",
          condition = length(selectors$var_y()$variables$selected) > 0,
          message = "Y-Axis Variable must be selected"
        )
      )
      shiny::validate(
        teal::need_input(
          inputId = c("var_x-variables-selected", "var_y-variables-selected"),
          condition = !any(selectors$var_x()$variables$selected %in% selectors$var_y()$variables$selected),
          message = "X-axis variable and Y-axis variable must be different"
        )
      )
      q <- merged$data()
      teal.reporter::teal_card(q) <- c(teal.reporter::teal_card(q), "## Module's output")
      q
    })

    # Generate plot inside qenv
    qenv_plot <- reactive({
      within(validated_q(), {
        plot <- ggplot2::ggplot(anl) +
          ggplot2::geom_point(ggplot2::aes(x = env_var_x, y = env_var_y))
      }, env_var_x = as.name(merged$variables()$var_x), env_var_y = as.name(merged$variables()$var_y))
    })
    decorated_plot <- teal::srv_transform_teal_data(
      "decorator_table",
      qenv_plot,
      select_decorators(decorators, "plot"),
      expr = quote(plot)
    )

    qenv_table <- reactive({
      within(validated_q(), {
        table <- gtsummary::tbl_summary(anl, by = env_var_x, missing = "no")
      }, env_var_x = as.name(merged$variables()$var_x), env_var_y = as.name(merged$variables()$var_y))
    })
    decorated_table <- teal::srv_transform_teal_data(
      "decorator_table",
      qenv_table,
      select_decorators(decorators, "table"),
      expr = quote(table)
    )

    # Output rendering: use ggplot2 for visualizations
    output$plot <- shiny::renderPlot(decorated_plot()[["plot"]])
    output$table <- gt::render_gt(expr = gtsummary::as_gt(decorated_table()[["table"]]))
     # Return reactive

    reactive(c(decorated_plot(), decorated_table()))
  })
}

tm_example_module <- function(
  label = "Example Module",
  var_x = teal.picks::picks(teal.picks::datasets(), teal.picks::variables(is.numeric, selected = 1L)),
  var_y = teal.picks::picks(teal.picks::datasets(), teal.picks::variables(is.numeric, selected = 2L)),
  decorators = list(),
  transformators = list()
) {
  checkmate::assert_string(label)
  checkmate::assert_class(var_x, "picks")
  checkmate::assert_class(var_y, "picks")
  checkmate::assert_list(transformators, types = "teal_transform_module")
  args <- list(var_x = var_x, var_y = var_y, decorators = decorators)
  teal::module(
    label = label,
    server = srv_example_module,
    ui = ui_example_module,
    ui_args = args[names(args) %in% names(formals(ui_example_module))],
    server_args = args[names(args) %in% names(formals(srv_example_module))],
    transformators = transformators
  )
}
```

### Code Style for Modules

- **Use `tidyverse` style**: Write clear, readable code using `dplyr`,
  `ggplot2` patterns
- **Use `magrittr` pipes in reproducible execution**: For code executed
  for `teal_data`/`qenv` data objects with `eval_code()` and `within()`
- **Use crane and gtsummary**: For statistical tables and summaries
- **Error handling**: Implement proper validation using `checkmate` and
  `shiny::validate(teal::need_input(...))`

``` r
# Good: Clear data manipulation
plot_data <- data %>%
  dplyr::filter(!is.na(variable)) %>%
  dplyr::group_by(category) %>%
  dplyr::summarise(
    mean_value = mean(value),
    n = dplyr::n(),
    .groups = "drop"
  )

# Good: Descriptive ggplot2 code
ggplot2::ggplot(plot_data, ggplot2::aes(x = category, y = mean_value)) +
  ggplot2::geom_col(fill = "steelblue") +
  ggplot2::labs(
    title = "Mean Values by Category",
    x = "Category",
    y = "Mean Value"
  ) +
  ggplot2::theme_minimal()
```

<!-- Ends Module Section -->

## Testing Framework

### Testing Philosophy

- **Test public functions only**: Internal utilities should be tested
  through public interfaces
- **Precise, focused tests**: Each test should verify one specific
  behavior
- **High coverage**: Maintain at least 80% test coverage as measured by
  `covr`
- **Integration over units**: Test realistic usage patterns
- **Test Dependencies**.: Add
  `testthat::skip_if_not_installed(package_name)` only for dependencies
  in `Suggests` or related to tests cases

### Shiny Module Testing

- **Server functions**: Test with `shiny::testServer()`
- **UI functions**: Test basic usage with regular testing (class checks,
  error generation, snapshots, regexp search). Test UI scenarios and
  interactions with `teal:::TealAppDriver` (based on
  `shinytest2::AppDriver`) for integration testing
- **Reactive behavior**: Test reactive chains and side effects

### Test Organization and Naming

- **One test file per R file**: `test-module_example.R` for
  `module_example.R`
- **Descriptive test names**: Clearly describe what is being tested
- **End to end test names**: `test-shinytest2-module_example.R` for
  `module_example.R`
- **Logical grouping**: Group related tests using `describe()` and
  individual tests with `it()` when beneficial
- **Test data**: Create minimal test datasets, avoid external
  dependencies

## Documentation and Communication

### Package Documentation

- **`README.md`**: Clear overview, installation, basic usage examples
- **Vignettes**: Comprehensive guides for complex functionality
- **Function documentation**: All exported functions must have
  `roxygen2` documentation
- **`NEWS.md`**: Detailed changelog of features, bugs and miscellanea
  changes affecting the users

### Package Version Management

Do not change versions on your own. There is a CI/CD workflow that
manages the versions automatically on the `main` branch.

## CI/CD and Development Workflow

Prefer to reuse templates from r.pkg.template. Main checks in place are:

- `check.yaml`: R CMD check, unit tests, coverage
- `docs.yaml`: Documentation building and deployment
- `audit.yaml`: Security and dependency auditing
- `pkgdown.yaml`: Website generation

## Quality Assurance

### Code Quality Metrics

- **Test Coverage**: ≥80% line coverage
- **Linting**: No lint violations using configured `.lintr`
- **Documentation**: 100% of exports documented

### Code Review Process

- **Pull Request Reviews**: All changes require human review and
  approval
- **Automated Checks**: CI must pass before merging
- **Breaking Changes**: Require special consideration and communication
- **Documentation Updates**: Must accompany functional changes

### Performance Considerations

- **Shiny Reactivity**: Minimize unnecessary reactive computations
- **Data Processing**: Use efficient data manipulation patterns
- **Memory Usage**: Consider memory implications for large datasets
- **Loading Time**: Optimize package loading and module initialization

## Maintenance Guidelines

- **Long-term Support**: Maintain backward compatibility when possible
- **Dependencies**: Minimal and justified dependencies only
- **Deprecation**: Use `lifecycle` package for function deprecation
