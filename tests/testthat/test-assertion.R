testthat::describe("check_last_level works", {
  it("checks last picks", {
    x <- list(datasets(), variables(), values())
    testthat::expect_match(check_last_level(x, "values"), "picks object")
  })

  it("checks last picks", {
    x <- picks(datasets(), variables(), values())
    testthat::expect_true(check_last_level(x, "values"))
  })

  it("returns FALSE", {
    x <- picks(datasets(), variables(), values())
    testthat::expect_match(check_last_level(x, "variables"), "in variables")
  })
})


testthat::describe("check_picks_has works", {
  p <- picks(datasets(), variables(), values())

  it("returns TRUE when element is present", {
    testthat::expect_true(check_picks(p, datasets = TRUE))
    testthat::expect_true(check_picks(p, variables = TRUE))
    testthat::expect_true(check_picks(p, values = TRUE))
  })

  it("returns an error string when element is absent", {
    p_no_values <- picks(datasets(), variables())
    testthat::expect_match(check_picks(p_no_values, values = TRUE), "requires values()")
  })

  it("returns an error string when x is not a picks object", {
    testthat::expect_match(check_picks(list()), "Must be a 'picks' object")
  })
})

testthat::describe("assert_picks", {
  p <- picks(datasets(), variables(), values())

  it("passes invisibly when element is present", {
    testthat::expect_invisible(assert_picks(p, datasets = TRUE))
    testthat::expect_invisible(assert_picks(p, variables = TRUE))
    testthat::expect_invisible(assert_picks(p, values = TRUE))
  })

  it("errors when element is absent", {
    p_no_values <- picks(datasets(), variables())
    testthat::expect_error(assert_picks(p_no_values, values = TRUE), "requires values()")
  })

  it("errors when x is not a picks object", {
    testthat::expect_error(assert_picks(list(), datasets = TRUE), "Must be a 'picks' object")
  })
})
