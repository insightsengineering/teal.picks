testthat::test_that("interaction_vars is compatible with eval_select", {
  testthat::expect_equal(
    unname(
      tidyselect::eval_select(
        interaction_vars("AGE", "RACE"),
        data = teal.data::rADSL
      )
    ),
    which(colnames(teal.data::rADSL) %in% c("AGE", "RACE"))
  ) |>
    testthat::expect_warning("interaction_vars() should only be used within a tidyselect context in teal.picks.",
      fixed = TRUE
    )
})

testthat::test_that("interaction_vars stores interactions in environment", {
  old <- select_env$operators
  old_active <- select_env$active
  withr::defer({
    select_env$operators <- old
    select_env$active <- old_active
  })
  select_env$active <- TRUE # mock a teal.picks context.
  select_env$operators <- NULL

  tidyselect::eval_select(
    c(interaction_vars(AGE, RACE), interaction_vars(AGE, COUNTRY)),
    data = teal.data::rADSL
  )
  testthat::expect_equal(
    select_env$operators,
    list(
      structure(c("AGE", "RACE"), class = c("interaction", "operator"), var_name = "AGE:RACE"),
      structure(c("AGE", "COUNTRY"), class = c("interaction", "operator"), var_name = "AGE:COUNTRY")
    )
  )
})

describe("interaction_vars filters table", {
  it("when specific values are subset", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        factor_var = factor(c("A", "B", "C", "A", "B"), levels = c("A", "B", "C")),
        factor_var2 = factor(c("B", "A", "B", "A", "C"), levels = c("A", "B", "C")),
        id = 1:5
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(teal.data::join_key("test_data", "test_data", "id"))

    selectors <- list(
      a = shiny::reactive(
        suppressWarnings(
          resolver(
            picks(
              datasets(choices = "test_data", selected = "test_data"),
              variables(
                choices = interaction_vars("factor_var", "factor_var2"),
                selected = c("factor_var:factor_var2")
              ),
              values(selected = c("A:B", "B:C"))
            ),
            data = data
          ),
          class = "picks_delayed"
        )
      )
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    expect_equal(
      out$data()$anl,
      within(data, {
        anl <- dplyr::select(test_data, id, factor_var, factor_var2) |>
          dplyr::filter(sprintf("%s:%s", factor_var, factor_var2) %in% c("A:B", "B:C"))
      })$anl
    )
  })
})
