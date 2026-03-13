testthat::describe("check_level works", {
  testthat::test_that("checks last picks", {
    x <- list(datasets(), variables(), values())
    testthat::expect_match(check_level(x, "values"), "picks object")
  })

  testthat::test_that("checks last picks", {
    x <- picks(datasets(), variables(), values())
    testthat::expect_true(check_level(x, "values"))
  })

  testthat::test_that("returns FALSE", {
    x <- picks(datasets(), variables(), values())
    testthat::expect_match(check_level(x, "variables"), "in variables")
  })
})
