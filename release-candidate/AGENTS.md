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
  - [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    is a list of `pick` objects named after their class:
    [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    first, followed by
    [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    and then
    [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  - a `pick` is `list(choices, selected)` with `multiple`, `fixed`,
    `ordered` and extra `pickerInput` options stored as attributes
  - `choices`/`selected` could be:
    - eager: `character` names, or plain values for
      [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
    - `tidyselect` expressions, quoted with
      [`rlang::enquo()`](https://rlang.r-lib.org/reference/enquo.html);
      integer positions such as the default `selected = 1L` count as
      `tidyselect`
    - predicate functions, e.g. `is.numeric`, applied to each element
      (functions with class `"des-delayed"` are called once with all the
      data); the only delayed form accepted by
      [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
- Shiny modules
  [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)/[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  render one input per `pick` and return a `reactiveVal`
  (`picks_resolved`) with the resolved `picks`
- Merging function
  [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  merges the selected data into one dataset (`anl` by default) and
  returns the merged `teal_data` and the selected variables

See `vignettes/teal-picks-in-teal.Rmd` for usage in `teal` modules and
`vignettes/teal-picks-standalone-shiny.Rmd` for standalone `shiny`
usage.

### Resolution of `picks`

- [`resolver()`](https://insightsengineering.github.io/teal.picks/reference/resolver.md)
  walks the `picks` in order: the
  [`determine()`](https://insightsengineering.github.io/teal.picks/reference/determine.md)
  S3 generic resolves `choices` and then `selected` of each element and
  passes the selected data to the next one (`teal_data` → dataset →
  selected columns).
- Names given as text are matched against the data and unknown ones are
  dropped silently (a warning appears only if none match):
  `variables(c("AGE", "SEXX"))` offers only `AGE`.
- [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  are resolved against the unique values of the selected columns.
- If an element ends up with nothing selected, every element after it is
  emptied (`choices` and `selected` become `NULL`).

### Inputs rendered by `picks_ui()`

- [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  only creates placeholders;
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  renders the inputs from the resolved `picks`.
- The
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  input depends on the type of the selected column:
  [`ranged()`](https://insightsengineering.github.io/teal.picks/reference/ranged.md)
  on a numeric column gives a `numericRangeInput()`, on a
  `Date`/`POSIXct` column a `dateRangeInput()`; anything else
  (character, factor, logical, or numeric without
  [`ranged()`](https://insightsengineering.github.io/teal.picks/reference/ranged.md))
  gives a `pickerInput()`.

### Reactive flow in `picks_srv()`

- Changing the dataset resets
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  and
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  to their defaults, and changing the variables resets
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  ([`.resolve()`](https://insightsengineering.github.io/teal.picks/reference/dot-resolve.md)).
- Categorical inputs
  ([`shinyWidgets::pickerInput()`](https://dreamrs.github.io/shinyWidgets/reference/pickerInput.html))
  commit only when the drop-down closes (`input$<element>-selected_open`
  becomes `FALSE`).
- Inputs are rendered again only when `choices` change
  (`bindEvent(choices())`); updating only `selected` in `picks_resolved`
  doesn’t update the input.

### Merge code generation

- [`.merge_summary_list()`](https://insightsengineering.github.io/teal.picks/reference/dot-merge_summary_list.md)
  checks the selections and `join_keys`, merges parents first (e.g.,
  `ADSL` before `ADAE`), renames duplicated columns (`AGE_ADAE`) and
  sets the `join_keys` of `anl`.
- `.merge_expr()` writes the merge code:
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  (keys always kept),
  [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
  only if
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  drop rows, then `join_fun` for each extra dataset, chained with `%>%`.

### Relationships with other packages

Direct dependencies:

- `teal.data`: `teal_data` and `join_keys`.
  - Any issue with `join_keys` should be addressed in `teal.data`.
- `teal.code`: reproducible code (`eval_code()`, `get_code()`).
- `teal`:
  [`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md)
  and
  [`teal_transform_filter()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  build
  [`teal::module()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html)/[`teal::teal_transform_module()`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_transform_module.html)
  objects.
- `tidyselect`: dynamic `choices`/`selected`.
- `teal.transform` is in `Suggests`;
  [`as.picks()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  converts `data_extract_spec`/`select_spec`/`filter_spec` to `picks` to
  ease the transition away from `teal.transform`.

Usage in other framework packages:

- Module packages (`teal.modules.general`, `teal.modules.clinical`,
  `teal.modules.gtsummary`, `teal.goshawk`) call
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md),
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  and
  [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  in their modules and the `app_driver_*()` helpers in their
  `shinytest2` tests, so changing these can break them. Open an issue
  before changing argument checks in
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  or
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
  - `teal.modules.general` is migrating from `teal.transform`: the
    `picks` version of each module is in a `tm_*_picks.R` file next to
    the old `data_extract_spec` version.

### Validating `picks`

Use the exported helpers instead of reading the structure or attributes
of `picks` directly:

- [`check_picks()`](https://insightsengineering.github.io/teal.picks/reference/assert_picks.md)/[`assert_picks()`](https://insightsengineering.github.io/teal.picks/reference/assert_picks.md):
  the object is a `picks` with the required elements (`datasets = TRUE`,
  `variables = TRUE`, `values = TRUE`).
- [`check_last_level()`](https://insightsengineering.github.io/teal.picks/reference/assert_last_level.md)/[`assert_last_level()`](https://insightsengineering.github.io/teal.picks/reference/assert_last_level.md):
  the last element is of a given class,
  e.g. `assert_last_level(x, "variables")`.
- [`is_pick_multiple()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md),
  [`is_pick_fixed()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md),
  [`is_pick_ordered()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md):
  read `pick` attributes instead of `attr(x, "multiple")`.
- [`picks_datanames()`](https://insightsengineering.github.io/teal.picks/reference/picks_datanames.md):
  datasets used by a set of `picks`, e.g. for a module’s `datanames`.

### Testing

- In `testServer()`, set `"variables-selected"` and then
  `"variables-selected_open" = FALSE` in two `session$setInputs()` calls
  before checking `picks_resolved()`. The input’s HTML is in
  `session$output[["variables-selected_container"]]$html`.
- In tests of other features, wrap only the
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  call in `suppressWarnings(classes = "picks_delayed")`: it warns
  whenever eager choices follow a dynamic element, including the default
  `selected = 1L`.
- In `shinytest2`, Shiny can’t see badge inputs until the badge is
  opened. Use
  [`app_driver_get_teal_picks_slot()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_get_teal_picks_slot.md)
  and
  [`app_driver_set_teal_picks_slot()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_set_teal_picks_slot.md).

### Debugging tips

- Check resolution without an app: `print(resolver(picks, data))`.
  `data` can be a `teal_data`, an environment or a named list.
- Errors in `choices`/`selected` functions or `tidyselect` are hidden:
  - Symptom: an empty picker and the warning “None of the
    `choices/selected` … Emptying choices…”.
  - To see the error, run it on the data:
    `tidyselect::eval_select(rlang::quo(c(Species, Sepal.Lenght)), iris)`.
  - Unlike text names, one unknown column in a `tidyselect` expression
    empties the whole selection; use
    [`tidyselect::any_of()`](https://tidyselect.r-lib.org/reference/all_of.html)
    for optional columns.
- `no applicable method for 'join_keys<-' ... 'qenv.error'` means the
  merge code failed:
  - To see the real error, run
    `teal.code::eval_code(data, teal.picks:::.merge_expr(teal.picks:::.merge_summary_list(selectors, teal.data::join_keys(data), "anl"), "anl", join_fun, data))`,
    with `selectors` a named list of resolved `picks`.
  - Common cause: `%>%` is not available. Run
    [`library(dplyr)`](https://dplyr.tidyverse.org) in the `teal_data`
    first;
    [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
    hides this because it attaches `testthat`, which exports `%>%`.
  - Common cause: a column is missing from a newly selected dataset
    (#56).
- Wrong results or missing columns in a module: check that the merged
  dataset has the required columns with `names(merged$data()[["anl"]])`
  and `merged$variables()` before debugging the module code.
- Debug logs:
  `logger::log_threshold("DEBUG", namespace = "teal.picks")`, or
  `TEAL.LOG_LEVEL=DEBUG` before loading.

This package is part of the teal framework. The following configuration
applies to all packages within the teal framework.

## Package Structure and Organization

### Key Directories

Follow the standard R package structure with teal-specific conventions:

```
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

## Modules Development

### Module features

Each module should produce one or more Table, Listing, or Graph (TLG):

- **Reproducibility**: All code being executed to generate TLGs should
  be run using `teal_data` and
  [`within()`](https://rdrr.io/r/base/with.html) /
  [`teal.code::eval_code()`](https://insightsengineering.github.io/teal.code/latest-tag/reference/eval_code.html)
  - At the end of the module this object should be returned to enable
    Reporter and “Show R code” functionalities
- **User Parameters**: Configurable inputs via
  [`teal.picks::picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  for flexible data selection
- **Transformators**: Optional pre-processing functions that derive
  variables and validate data before analysis
- **Decorators**: Optional post-processing functions that customize
  output presentation (titles, legends, annotations)

### Module Architecture

Teal modules follow a specific pattern with UI and server components:

\
`# UI Function`\
`ui_example_module`` ``<-`` ``function``(``id``, ``var_x``, ``var_y``, ``decorators``)`` ``{`\
`  ``ns`` ``<-`` ``shiny``::`[`NS`](https://rdrr.io/pkg/shiny/man/NS.html)`(``id``)`\
`  ``select_decorators`` ``<-`` `[`getFromNamespace`](https://rdrr.io/r/utils/getFromNamespace.html)`(``"select_decorators"``, ``"teal"``)`` ``# import from teal internal functions`\
\
`  ``shiny``::`[`tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)`(`\
`    ``# Input controls`\
`    ``teal.widgets``::`[`standard_layout`](https://insightsengineering.github.io/teal.widgets/latest-tag/reference/standard_layout.html)`(`\
`      ``# Output displays`\
`      output ``=`` ``teal.widgets``::`[`white_small_well`](https://insightsengineering.github.io/teal.widgets/latest-tag/reference/white_small_well.html)`(`\
`        ``teal``::`[`ui_transform_teal_data`](https://insightsengineering.github.io/teal/latest-tag/reference/module_transform_data.html)`(``"decorator_table"``, ``select_decorators``(``decorators``, ``"plot"``)``)``,`\
`        ``teal``::`[`ui_transform_teal_data`](https://insightsengineering.github.io/teal/latest-tag/reference/module_transform_data.html)`(``"decorator_table"``, ``select_decorators``(``decorators``, ``"table"``)``)``,`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``h4``(``"Results"``)``,`\
`        ``shiny``::`[`plotOutput`](https://rdrr.io/pkg/shiny/man/plotOutput.html)`(``ns``(``"plot"``)``)``,`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``h4``(``"Summary data"``)``,`\
`        ``gt``::`[`gt_output`](https://gt.rstudio.com/reference/gt_output.html)`(``ns``(``"table"``)``)`\
`      ``)``,`\
`      ``# Encoding panel`\
`      encoding ``=`` ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``div``(`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``label``(``"Encodings"``, class ``=`` ``"text-primary"``)``,`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``br``(``)``,`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``div``(`\
`          ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``strong``(``"Select X-Axis Variable"``)``,`\
`          ``teal.picks``::`[`picks_ui`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)`(``ns``(``"var_x"``)``, ``var_x``)`\
`        ``)``,`\
`        ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``div``(`\
`          ``shiny``::`[`tags`](https://rstudio.github.io/htmltools/reference/builder.html)`$``strong``(``"Select Y-Axis Variable"``)``,`\
`          ``teal.picks``::`[`picks_ui`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)`(``ns``(``"var_y"``)``, ``var_y``)`\
`        ``)`\
`      ``)`\
`    ``)`\
`  ``)`\
`}`\
\
`# Server Function`\
`srv_example_module`` ``<-`` ``function``(``id``, ``data``, ``var_x``, ``var_y``, ``decorators``)`` ``{`\
`  ``checkmate``::`[`assert_string`](https://mllg.github.io/checkmate/reference/checkString.html)`(``id``)`\
`  ``checkmate``::`[`assert_class`](https://mllg.github.io/checkmate/reference/checkClass.html)`(``data``, ``"reactive"``)`\
\
`  ``select_decorators`` ``<-`` `[`getFromNamespace`](https://rdrr.io/r/utils/getFromNamespace.html)`(``"select_decorators"``, ``"teal"``)`` ``# import from teal internal functions`\
`  ``shiny``::`[`moduleServer`](https://rdrr.io/pkg/shiny/man/moduleServer.html)`(``id``, ``function``(``input``, ``output``, ``session``)`` ``{`\
`    ``selectors`` ``<-`` ``teal.picks``::`[`picks_srv`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)`(``"picks"``, picks ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``var_x ``=`` ``var_x``, var_y ``=`` ``var_y``)``, data ``=`` ``data``)`\
`    ``merged`` ``<-`` ``teal.picks``::`[`merge_srv`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)`(`\
`      ``"merge_picks"``,`\
`      data ``=`` ``data``,`\
`      selectors ``=`` ``selectors``,`\
`      output_name ``=`` ``"anl"``,`\
`      join_fun ``=`` ``"dplyr::inner_join"`\
`    ``)`\
`    ``# Data preparation`\
`    ``validated_q`` ``<-`` ``shiny``::`[`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)`(``{`\
`      ``shiny``::`[`validate`](https://rdrr.io/pkg/shiny/man/validate.html)`(`\
`        ``teal``::`[`need_input`](https://insightsengineering.github.io/teal/latest-tag/reference/validate_input.html)`(`\
`          inputId ``=`` ``"var_x-variables-selected"``,`\
`          condition ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``selectors``$``var_x``(``)``$``variables``$``selected``)`` ``>`` ``0``,`\
`          message ``=`` ``"X-Axis Variable must be selected"`\
`        ``)``,`\
`        ``teal``::`[`need_input`](https://insightsengineering.github.io/teal/latest-tag/reference/validate_input.html)`(`\
`          inputId ``=`` ``"var_y-variables-selected"``,`\
`          condition ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``selectors``$``var_y``(``)``$``variables``$``selected``)`` ``>`` ``0``,`\
`          message ``=`` ``"Y-Axis Variable must be selected"`\
`        ``)`\
`      ``)`\
`      ``shiny``::`[`validate`](https://rdrr.io/pkg/shiny/man/validate.html)`(`\
`        ``teal``::`[`need_input`](https://insightsengineering.github.io/teal/latest-tag/reference/validate_input.html)`(`\
`          inputId ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"var_x-variables-selected"``, ``"var_y-variables-selected"``)``,`\
`          condition ``=`` ``!`[`any`](https://rdrr.io/r/base/any.html)`(``selectors``$``var_x``(``)``$``variables``$``selected`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``selectors``$``var_y``(``)``$``variables``$``selected``)``,`\
`          message ``=`` ``"X-axis variable and Y-axis variable must be different"`\
`        ``)`\
`      ``)`\
`      ``q`` ``<-`` ``merged``$``data``(``)`\
`      ``teal.reporter``::`[`teal_card`](https://insightsengineering.github.io/teal.reporter/latest-tag/reference/teal_card.html)`(``q``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``teal.reporter``::`[`teal_card`](https://insightsengineering.github.io/teal.reporter/latest-tag/reference/teal_card.html)`(``q``)``, ``"## Module's output"``)`\
`      ``q`\
`    ``}``)`\
\
`    ``# Generate plot inside qenv`\
`    ``qenv_plot`` ``<-`` ``reactive``(``{`\
`      `[`within`](https://rdrr.io/r/base/with.html)`(``validated_q``(``)``, ``{`\
`        ``plot`` ``<-`` ``ggplot2``::`[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``anl``)`` ``+`\
`          ``ggplot2``::`[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(``ggplot2``::`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``env_var_x``, y ``=`` ``env_var_y``)``)`\
`      ``}``, env_var_x ``=`` `[`as.name`](https://rdrr.io/r/base/name.html)`(``merged``$``variables``(``)``$``var_x``)``, env_var_y ``=`` `[`as.name`](https://rdrr.io/r/base/name.html)`(``merged``$``variables``(``)``$``var_y``)``)`\
`    ``}``)`\
`    ``decorated_plot`` ``<-`` ``teal``::`[`srv_transform_teal_data`](https://insightsengineering.github.io/teal/latest-tag/reference/module_transform_data.html)`(`\
`      ``"decorator_table"``,`\
`      ``qenv_plot``,`\
`      ``select_decorators``(``decorators``, ``"plot"``)``,`\
`      expr ``=`` `[`quote`](https://rdrr.io/r/base/substitute.html)`(``plot``)`\
`    ``)`\
\
`    ``qenv_table`` ``<-`` ``reactive``(``{`\
`      `[`within`](https://rdrr.io/r/base/with.html)`(``validated_q``(``)``, ``{`\
`        ``table`` ``<-`` ``gtsummary``::`[`tbl_summary`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)`(``anl``, by ``=`` ``env_var_x``, missing ``=`` ``"no"``)`\
`      ``}``, env_var_x ``=`` `[`as.name`](https://rdrr.io/r/base/name.html)`(``merged``$``variables``(``)``$``var_x``)``, env_var_y ``=`` `[`as.name`](https://rdrr.io/r/base/name.html)`(``merged``$``variables``(``)``$``var_y``)``)`\
`    ``}``)`\
`    ``decorated_table`` ``<-`` ``teal``::`[`srv_transform_teal_data`](https://insightsengineering.github.io/teal/latest-tag/reference/module_transform_data.html)`(`\
`      ``"decorator_table"``,`\
`      ``qenv_table``,`\
`      ``select_decorators``(``decorators``, ``"table"``)``,`\
`      expr ``=`` `[`quote`](https://rdrr.io/r/base/substitute.html)`(``table``)`\
`    ``)`\
\
`    ``# Output rendering: use ggplot2 for visualizations`\
`    ``output``$``plot`` ``<-`` ``shiny``::`[`renderPlot`](https://rdrr.io/pkg/shiny/man/renderPlot.html)`(``decorated_plot``(``)``[[``"plot"``]``]``)`\
`    ``output``$``table`` ``<-`` ``gt``::`[`render_gt`](https://gt.rstudio.com/reference/render_gt.html)`(``expr ``=`` ``gtsummary``::`[`as_gt`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html)`(``decorated_table``(``)``[[``"table"``]``]``)``)`\
`     ``# Return reactive`\
\
`    ``reactive``(`[`c`](https://rdrr.io/r/base/c.html)`(``decorated_plot``(``)``, ``decorated_table``(``)``)``)`\
`  ``}``)`\
`}`\
\
`tm_example_module`` ``<-`` ``function``(`\
`  ``label`` ``=`` ``"Example Module"``,`\
`  ``var_x`` ``=`` ``teal.picks``::`[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``teal.picks``::`[`datasets`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``)``, ``teal.picks``::`[`variables`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``is.numeric``, selected ``=`` ``1L``)``)``,`\
`  ``var_y`` ``=`` ``teal.picks``::`[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``teal.picks``::`[`datasets`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``)``, ``teal.picks``::`[`variables`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``is.numeric``, selected ``=`` ``2L``)``)``,`\
`  ``decorators`` ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``)``,`\
`  ``transformators`` ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`)`` ``{`\
`  ``checkmate``::`[`assert_string`](https://mllg.github.io/checkmate/reference/checkString.html)`(``label``)`\
`  ``checkmate``::`[`assert_class`](https://mllg.github.io/checkmate/reference/checkClass.html)`(``var_x``, ``"picks"``)`\
`  ``checkmate``::`[`assert_class`](https://mllg.github.io/checkmate/reference/checkClass.html)`(``var_y``, ``"picks"``)`\
`  ``checkmate``::`[`assert_list`](https://mllg.github.io/checkmate/reference/checkList.html)`(``transformators``, types ``=`` ``"teal_transform_module"``)`\
`  ``args`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``var_x ``=`` ``var_x``, var_y ``=`` ``var_y``, decorators ``=`` ``decorators``)`\
`  ``teal``::`[`module`](https://insightsengineering.github.io/teal/latest-tag/reference/teal_modules.html)`(`\
`    label ``=`` ``label``,`\
`    server ``=`` ``srv_example_module``,`\
`    ui ``=`` ``ui_example_module``,`\
`    ui_args ``=`` ``args``[`[`names`](https://rdrr.io/r/base/names.html)`(``args``)`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(`[`formals`](https://rdrr.io/r/base/formals.html)`(``ui_example_module``)``)``]``,`\
`    server_args ``=`` ``args``[`[`names`](https://rdrr.io/r/base/names.html)`(``args``)`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(`[`formals`](https://rdrr.io/r/base/formals.html)`(``srv_example_module``)``)``]``,`\
`    transformators ``=`` ``transformators`\
`  ``)`\
`}`

### Code Style for Modules

- **Use `tidyverse` style**: Write clear, readable code using `dplyr`,
  `ggplot2` patterns
- **Use `magrittr` pipes in reproducible execution**: For code executed
  for `teal_data`/`qenv` data objects with `eval_code()` and
  [`within()`](https://rdrr.io/r/base/with.html)
- **Use crane and gtsummary**: For statistical tables and summaries
- **Error handling**: Implement proper validation using `checkmate` and
  `shiny::validate(teal::need_input(...))`

\
`# Good: Clear data manipulation`\
`plot_data`` ``<-`` ``data`` ``%>%`\
`  ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``variable``)``)`` ``%>%`\
`  ``dplyr``::`[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``category``)`` ``%>%`\
`  ``dplyr``::`[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    mean_value ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``value``)``,`\
`    n ``=`` ``dplyr``::`[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    .groups ``=`` ``"drop"`\
`  ``)`\
\
`# Good: Descriptive ggplot2 code`\
`ggplot2``::`[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``plot_data``, ``ggplot2``::`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``category``, y ``=`` ``mean_value``)``)`` ``+`\
`  ``ggplot2``::`[`geom_col`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``fill ``=`` ``"steelblue"``)`` ``+`\
`  ``ggplot2``::`[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Mean Values by Category"``,`\
`    x ``=`` ``"Category"``,`\
`    y ``=`` ``"Mean Value"`\
`  ``)`` ``+`\
`  ``ggplot2``::`[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

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

- **Server functions**: Test with
  [`shiny::testServer()`](https://rdrr.io/pkg/shiny/man/testServer.html)
- **UI functions**: Test basic usage with regular testing (class checks,
  error generation, snapshots, regexp search). Test UI scenarios and
  interactions with `teal:::TealAppDriver` (based on
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html))
  for integration testing
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
