#' Merge Server Function for Dataset Integration
#'
#' @description
#' `merge_srv` is a powerful Shiny server function that orchestrates the merging of multiple datasets
#' based on user selections from `picks` objects. It creates a reactive merged dataset (`teal_data` object)
#' and tracks which variables from each selector are included in the final merged output.
#'
#' This function serves as the bridge between user interface selections (managed by selectors) and
#' the actual data merging logic. It automatically handles:
#' - Dataset joining based on join keys
#' - Variable selection and renaming to avoid conflicts
#' - Reactive updates when user selections change
#' - Generation of reproducible R code for the merge operation
#'
#' @param id (`character(1)`) Module ID for the Shiny module namespace
#' @param data (`reactive`) A reactive expression returning a [teal.data::teal_data] object containing
#'   the source datasets to be merged. This object must have join keys defined via
#'   [teal.data::join_keys()] to enable proper dataset relationships.
#' @param selectors (`named list`) A named list of selector objects. Each element can be:
#'   - A `picks` object defining dataset and variable selections
#'   - A `reactive` expression returning a `picks` object
#'   The names of this list are used as identifiers for tracking which variables come from which selector.
#' @param output_name (`character(1)`) Name of the merged dataset that will be created in the
#'   returned `teal_data` object. Default is `"anl"`. This name will be used in the generated R code.
#' @param join_fun (`character(1)`) The joining function to use for merging datasets. Must be a
#'   qualified function name (e.g., `"dplyr::left_join"`, `"dplyr::inner_join"`, `"dplyr::full_join"`).
#'   Default is `"dplyr::inner_join"`. The function must accept `by` and `suffix` parameters.
#'
#' @return A `list` with two reactive elements:
#'  - `data`A `reactive` returning a [teal.data::teal_data] object containing the merged dataset.
#'     The merged dataset is named according to `output_name` parameter. The `teal_data` object includes:
#'     - The merged dataset with all selected variables
#'     - Complete R code to reproduce the merge operation
#'     - Updated join keys reflecting the merged dataset structure
#'  - `variables` A `reactive` returning a named list mapping selector names to their selected
#'     variables in the merged dataset. The structure is:
#'     `list(selector_name_1 = c("var1", "var2"), selector_name_2 = c("var3", "var4"), ...)`.
#'     Variable names reflect any renaming that occurred during the merge to avoid conflicts.
#'
#' @section How It Works:
#'
#' The `merge_srv` function performs the following steps:
#'
#' 1. **Receives Input Data**: Takes a reactive `teal_data` object containing source datasets with
#'    defined join keys
#'
#' 2. **Processes Selectors**: Evaluates each selector (whether static `picks` or reactive) to
#'    determine which datasets and variables are selected
#'
#' 3. **Determines Merge Order**: Uses topological sort based on the `join_keys` to determine
#'    the optimal order for merging datasets.
#'
#' 4. **Handles Variable Conflicts**: Automatically renames variables when:
#'    - Multiple selectors choose variables with the same name from different datasets
#'    - Foreign key variables would conflict with existing variables
#'    - Renaming follows the pattern `{column-name}_{dataset-name}`
#'
#' 5. **Performs Merge**: Generates and executes merge code that:
#'    - Selects only required variables from each dataset
#'    - Applies any filters defined in selectors
#'    - Joins datasets using specified join function and join keys
#'    - Maintains reproducibility through generated R code
#'
#' 6. **Updates Join Keys**: Creates new join key relationships for the merged dataset (`"anl"`)
#'    relative to remaining datasets in the `teal_data` object
#'
#' 7. **Tracks Variables**: Keeps track of the variable names in the merged dataset
#'
#' @section Usage Pattern:
#'
#' ```r
#' # In your Shiny server function
#' merged <- merge_srv(
#'   id = "merge",
#'   data = reactive(my_teal_data),
#'   selectors = list(
#'     selector1 = picks(...),
#'     selector2 = reactive(picks(...))
#'   ),
#'   output_name = "anl",
#'   join_fun = "dplyr::left_join"
#' )
#'
#' # Access merged data
#' merged_data <- merged$data()  # teal_data object with merged dataset
#' anl <- merged_data[["anl"]]   # The actual merged data.frame/tibble
#'
#' # Get variable mapping
#' vars <- merged$variables()
#' # Returns: list(selector1 = c("VAR1", "VAR2"), selector2 = c("VAR3", "VAR4_ADSL"))
#'
#' # Get reproducible code
#' code <- teal.code::get_code(merged_data)
#' ```
#'
#' @section Merge Logic Details:
#'
#' **Dataset Order**: Datasets are merged in topological order based on join keys. The first dataset
#' acts as the "left" side of the join, and subsequent datasets are joined one by one.
#'
#' **Join Keys**: The function uses join keys from the source `teal_data` object to determine:
#' - Which datasets can be joined together
#' - Which columns to use for joining (the `by` parameter)
#' - Whether datasets need intermediate joins (not yet implemented)
#'
#' **Variable Selection**: For each dataset being merged:
#' - Selects user-chosen variables from selectors
#' - Includes foreign key variables needed for joining (even if not explicitly selected)
#' - Removes duplicate foreign keys after join (they're already in the left dataset)
#'
#' **Conflict Resolution**: When variable names conflict:
#' - Variables from later datasets get suffixed with `_dataname`
#' - Foreign keys that match are merged (not duplicated)
#' - The mapping returned in `merge_vars` reflects the final names
#'
#' @section Integration with Selectors:
#'
#' `merge_srv` is designed to work with [picks_srv()] which creates selector objects:
#'
#' ```r
#' # Create selectors in server
#' selectors <- picks_srv(
#'   picks =  list(
#'     adsl = picks(...),
#'     adae = picks(...)
#'   ),
#'   data = data
#' )
#'
#' # Pass to merge_srv
#' merged <- merge_srv(
#'   id = "merge",
#'   data = data,
#'   selectors = selectors
#' )
#' ```
#'
#' @seealso
#' - [picks_srv()] for creating selectors
#' - [teal.data::join_keys()] for defining dataset relationships
#'
#' @examples
#' # Complete example with CDISC data
#' library(teal.transform)
#' library(teal.data)
#' library(shiny)
#'
#' # Prepare data with join keys
#' data <- teal_data()
#' data <- within(data, {
#'   ADSL <- teal.data::rADSL
#'   ADAE <- teal.data::rADAE
#' })
#' join_keys(data) <- default_cdisc_join_keys[c("ADSL", "ADAE")]
#'
#' # Create Shiny app
#' ui <- fluidPage(
#'   picks_ui("adsl", picks(datasets("ADSL"), variables())),
#'   picks_ui("adae", picks(datasets("ADAE"), variables())),
#'   verbatimTextOutput("code"),
#'   verbatimTextOutput("vars")
#' )
#'
#' server <- function(input, output, session) {
#'   # Create selectors
#'   selectors <- list(
#'     adsl = picks_srv("adsl",
#'       data = reactive(data),
#'       picks = picks(datasets("ADSL"), variables())
#'     ),
#'     adae = picks_srv("adae",
#'       data = reactive(data),
#'       picks = picks(datasets("ADAE"), variables())
#'     )
#'   )
#'
#'   # Merge datasets
#'   merged <- merge_srv(
#'     id = "merge",
#'     data = reactive(data),
#'     selectors = selectors,
#'     output_name = "anl",
#'     join_fun = "dplyr::left_join"
#'   )
#'
#'   # Display results
#'   output$code <- renderPrint({
#'     cat(teal.code::get_code(merged$data()))
#'   })
#'
#'   output$vars <- renderPrint({
#'     merged$variables()
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
#' @export
merge_srv <- function(id,
                      data,
                      selectors,
                      output_name = "anl",
                      join_fun = "dplyr::inner_join") {
  checkmate::assert_list(selectors, "reactive", names = "named")
  checkmate::assert_class(data, "reactive")
  checkmate::assert_string(output_name)
  checkmate::assert_string(join_fun)
  moduleServer(id, function(input, output, session) {
    # selectors is a list of reactive picks.
    selectors_unwrapped <- reactive({
      lapply(selectors, function(x) req(x()))
    })

    data_r <- reactive({
      req(data(), selectors_unwrapped())
      .qenv_merge(
        data(),
        selectors = selectors_unwrapped(),
        output_name = output_name,
        join_fun = join_fun
      )
    })

    variables_selected <- eventReactive(
      selectors_unwrapped(),
      {
        req(selectors_unwrapped())
        lapply(
          .merge_summary_list(selectors_unwrapped(), join_keys = teal.data::join_keys(data()))$mapping,
          function(selector) unname(selector$variables)
        )
      }
    )

    list(data = data_r, variables = variables_selected)
  })
}


#' @keywords internal
.qenv_merge <- function(x,
                        selectors,
                        output_name = "anl",
                        join_fun = "dplyr::left_join") {
  checkmate::assert_class(x, "teal_data")
  checkmate::assert_list(selectors, "picks", names = "named")
  checkmate::assert_string(join_fun)

  # Early validation of merge keys between datasets
  merge_summary <- .merge_summary_list(selectors, join_keys = teal.data::join_keys(x))

  expr <- .merge_expr(merge_summary = merge_summary, output_name = output_name, join_fun = join_fun)

  merged_q <- teal.code::eval_code(x, expr)
  teal.data::join_keys(merged_q) <- merge_summary$join_keys
  merged_q
}


#' @keywords internal
.merge_expr <- function(merge_summary,
                        output_name = "anl",
                        join_fun = "dplyr::left_join") {
  checkmate::assert_list(merge_summary)
  checkmate::assert_string(output_name)
  checkmate::assert_string(join_fun)

  join_keys <- merge_summary$join_keys
  mapping <- merge_summary$mapping
  mapping <- lapply(mapping, function(x) {
    # because we need `$new_name = $old_name` to rename in select call
    x$variables <- stats::setNames(names(x$variables), unname(x$variables))
    x
  })
  datanames <- unique(unlist(lapply(mapping, `[[`, "datasets")))
  calls <- expression()
  anl_datanames <- character(0) # to follow what anl is composed of (to determine keys)
  anl_primary_keys <- character(0) # to determine accumulated keys of anl
  for (i in seq_along(datanames)) {
    dataname <- datanames[i]
    this_mapping <- Filter(function(x) x$datasets == dataname, mapping)
    this_filter_mapping <- Filter(
      x = this_mapping, function(x) !is.null(x$values) && !is.null(x$variables)
    )
    this_foreign_keys <- .fk(join_keys, dataname)
    this_primary_keys <- join_keys[dataname, dataname]
    this_variables <- c(
      this_foreign_keys,
      unlist(lapply(unname(this_mapping), `[[`, "variables"))
    )
    this_variables <- this_variables[!duplicated(unname(this_variables))] # because unique drops names

    this_call <- .call_dplyr_select(dataname = dataname, variables = this_variables)
    this_call <- calls_combine_by("%>%", c(this_call, .call_dplyr_filter(this_filter_mapping)))

    if (i > 1) {
      anl_vs_this <- setdiff(anl_primary_keys, this_primary_keys)
      this_vs_anl <- setdiff(this_primary_keys, anl_primary_keys)
      if (length(anl_vs_this) && length(this_vs_anl)) {
        warning("cartesian join - happens when primary keys A is not a subset of B and B is not a subset of A")
      }
      this_call <- as.call(
        list(
          str2lang(join_fun),
          y = this_call,
          by = join_keys["anl", dataname],
          suffix = c("", sprintf("_%s", dataname))
        )
      )
    }

    anl_datanames <- c(anl_datanames, dataname)
    anl_primary_keys <- union(anl_primary_keys, this_primary_keys)
    calls <- c(calls, this_call)
  }

  call("<-", str2lang(output_name), calls_combine_by("%>%", calls))
}


#' Analyse selectors and concludes a merge parameters
#'
#' @return list containing:
#' - mapping (`named list`) containing selected values in each selector. This `mapping`
#'   is sorted according to correct datasets merge order. `variables` contains names of the
#'   variables in `ANL`
#' - join_keys (`join_keys`) updated `join_keys` containing keys of `ANL`
#'
#' @keywords internal
.merge_summary_list <- function(selectors, join_keys) {
  checkmate::assert_list(selectors, "picks")
  checkmate::assert_class(join_keys, "join_keys")

  .validate_is_eager(selectors)
  .validate_join_keys(selectors, join_keys)

  mapping <- lapply( # what has been selected in each selector
    selectors,
    function(selector) {
      lapply(selector, function(x) {
        stats::setNames(x$selected, x$selected)
      })
    }
  )

  mapped_datanames <- unlist(lapply(mapping, `[[`, "datasets"), use.names = FALSE)
  mapping_by_dataset <- split(mapping, mapped_datanames)

  datanames <- unique(mapped_datanames)
  if (length(datanames) > 1) {
    # datanames are handed over in order of selectors but
    # they must be in topological order - otherwise join might not be possible
    datanames <- c(
      intersect(names(join_keys), datanames), # join_keys are in topological order
      setdiff(datanames, names(join_keys)) # non-joinable datasets at the end
    )

    # mapping will be reused so needs to be reordered as well
    mapping <- mapping[order(match(mapped_datanames, datanames))]
  }
  remaining_datanames <- datanames
  join_keys <- join_keys[datanames]
  anl_colnames <- character(0)
  for (dataname in datanames) {
    #   glossary:
    #     dataset/dataname: dataset (or its name) in the current iteration (datasets are merged in a loop)
    #     anl datasets/datanames: datasets (or names) which anl is composed of (this is a cumulative process)
    #     remaining datasets/datanames: datasets (or names) which are about to be merged
    #
    # Rules:
    #   1. anl "inherits" foreign keys from anl datasets to remaining datasets
    #   2. foreign keys of current dataset are added to anl join_keys but only if no relation from anl already.
    #   3. foreign keys should be renamed if duplicated with anl colnames
    #   4. (for later) selected datasets might not be directly mergable, we need to find the "path" which
    #     will probably involve add intermediate datasets in between to perform merge
    #   5. selected variables are added to anl.
    #   6. duplicated variables added to anl should be renamed
    remaining_datanames <- setdiff(remaining_datanames, dataname)

    # ↓  1. anl "inherits" foreign keys from anl datasets to remaining datasets
    this_join_keys <- do.call(
      teal.data::join_keys,
      lapply(
        remaining_datanames,
        function(dataset_2) {
          new_keys <- join_keys[dataname, dataset_2]
          # ↓ 2. foreign keys of current dataset are added to anl join_keys but only if no relation from anl already
          if (length(new_keys) && !dataset_2 %in% names(join_keys[["anl"]])) {
            # ↓ 3. foreign keys should be renamed if duplicated with anl colnames
            new_key_names <- .suffix_duplicated_vars(
              vars = names(new_keys), # names because we change the key of dataset_1 (not dataset_2)
              all_vars = anl_colnames,
              suffix = dataname
            )
            names(new_keys) <- new_key_names
            teal.data::join_key(dataset_1 = "anl", dataset_2 = dataset_2, keys = new_keys)
          }
        }
      )
    )
    join_keys <- c(this_join_keys, join_keys)


    mapping_ds <- mapping_by_dataset[[dataname]]
    mapping_ds <- lapply(mapping_ds, function(x) {
      new_vars <- .suffix_duplicated_vars(
        #       is dropped by merge call. We should refer this selected foreign-key-variable
        #       to equivalent key variable added in previous iteration (existing anl foreign key)
        # 6. duplicated variables added to anl should be renamed
        vars = x$variables,
        all_vars = anl_colnames,
        suffix = dataname
      )

      # if foreign key of this dataset is selected and if this foreign key took a part in the merge
      #  then this key is dropped and we need to refer to the first variable
      existing_fk <- join_keys[dataname, "anl"] # keys that are already in anl
      existing_fk_selected <- intersect(names(existing_fk), x$variables)
      new_vars[existing_fk_selected] <- existing_fk[existing_fk_selected]
      x$variables <- new_vars
      x
    })
    mapping[names(mapping_ds)] <- mapping_ds

    this_colnames <- unique(unlist(lapply(mapping_ds, `[[`, "variables")))
    anl_colnames <- c(anl_colnames, this_colnames)

    anl_colnames <- union(anl_colnames, .fk(join_keys, "anl"))
  }


  list(mapping = mapping, join_keys = join_keys)
}

.fk <- function(x, dataname) {
  this_jk <- x[[dataname]]
  unique(unlist(lapply(this_jk[!names(this_jk) %in% dataname], names)))
}

.suffix_duplicated_vars <- function(vars, all_vars, suffix) {
  names <- names(vars)
  idx_duplicated <- vars %in% all_vars
  if (any(idx_duplicated)) {
    # make sure that names are unchanged!
    vars[idx_duplicated] <- sprintf("%s_%s", vars[idx_duplicated], suffix)
  }
  vars
}

#' Check if datasets can be merged in topological order
#'
#' Determines the topological order from join_keys, then checks that each dataset
#' can be joined with at least one of the previously accumulated datasets.
#'
#' @inheritParams merge_srv
#' @param join_keys (`join_keys`) The join keys object
#'
#' @keywords internal
.validate_join_keys <- function(selectors, join_keys) {
  validate(need(
    inherits(join_keys, "join_keys"),
    "Provided data doesn't have join_keys specified"
  ))

  datanames <- unique(unlist(lapply(selectors, function(selector) selector$datasets$selected)))
  # No validation needed for single dataset
  if (length(datanames) <= 1) {
    return(TRUE)
  }

  # Get topological order from join_keys (this is the canonical ordering)
  topological_order <- names(join_keys)

  # Filter to only selected datasets and maintain topological order
  ordered_datasets <- intersect(topological_order, datanames)

  # Check if any dataset has no keys defined at all
  if (length(ordered_datasets) != length(datanames)) {
    datasets_without_keys <- setdiff(datanames, ordered_datasets)
    validate(
      need(
        FALSE,
        sprintf(
          "Cannot merge datasets. The following dataset%s no join keys defined: %s.\n\nPlease define `join_keys`.",
          if (length(datasets_without_keys) == 1) " has" else "s have",
          paste(sprintf("'%s'", datasets_without_keys), collapse = ", ")
        )
      )
    )
  }

  # Iteratively check if each dataset can join with accumulated datasets
  accumulated <- ordered_datasets[1]

  for (i in seq(2, length(ordered_datasets))) {
    current_dataset <- ordered_datasets[i]
    can_join <- FALSE

    # Check if current dataset has join keys with ANY accumulated dataset
    for (prev_dataset in accumulated) {
      if (length(join_keys[current_dataset, prev_dataset]) > 0) {
        can_join <- TRUE
        break
      }
    }

    if (!can_join) {
      validate(
        need(
          FALSE,
          sprintf(
            paste(
              "Cannot merge dataset '%s'. No join keys found between '%s' and any of the accumulated datasets:",
              "%s.\n\nPlease define join keys using teal.data::join_keys()."
            ),
            current_dataset,
            current_dataset,
            paste(sprintf("'%s'", accumulated), collapse = ", ")
          )
        )
      )
    }

    # Add current dataset to accumulated
    accumulated <- c(accumulated, current_dataset)
  }

  TRUE
}

.validate_is_eager <- function(x) {
  validate(need(
    !.is_delayed(x),
    "selected values have not been resolved correctly. Please report this issue to an app-developer."
  ))
}
