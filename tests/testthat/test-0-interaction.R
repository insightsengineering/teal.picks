testthat::test_that("interaction_vars is compatible with eval_select", {
  expect_equal(
    unname(
      tidyselect::eval_select(
        interaction_vars("AGE", "RACE"),
        data = teal.data::rADSL
      )
    ),
    which(colnames(teal.data::rADSL) %in% c("AGE", "RACE"))
  )
})

testthat::test_that("interaction_vars stores interactions in environment", {
  old <- select_env$operators
  old_active <- select_env$active
  withr::defer({
    select_env$operators <- old
    select_env$active <- old_active
  })
  select_env$active <- TRUE
  select_env$operators <- NULL

  tidyselect::eval_select(
    c(interaction_vars(AGE, RACE), interaction_vars(AGE, COUNTRY)),
    data = teal.data::rADSL
  )
  expect_equal(
    select_env$operators,
    list(
      structure(c("AGE", "RACE"), class = "interaction", var_name = "AGE:RACE"),
      structure(c("AGE", "COUNTRY"), class = "interaction", var_name = "AGE:COUNTRY")
    )
  )
})
