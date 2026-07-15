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
    testthat::expect_true(check_picks_has(p, "datasets"))
    testthat::expect_true(check_picks_has(p, "variables"))
    testthat::expect_true(check_picks_has(p, "values"))
  })

  it("returns string when element is absent", {
    p_no_values <- picks(datasets(), variables())
    testthat::expect_match(check_picks_has(p_no_values, "values"), "does not contain")
  })

  it("returns string for invalid element argument", {
    testthat::expect_match(check_picks_has(p, "other"), "must be one of")
  })

  it("returns string when x is not a picks object", {
    testthat::expect_match(check_picks_has(list(), "datasets"), "picks")
  })
})

testthat::describe("assert_picks_has works", {
  p <- picks(datasets(), variables(), values())

  it("passes invisibly when element is present", {
    testthat::expect_invisible(assert_picks_has(p, "datasets"))
    testthat::expect_invisible(assert_picks_has(p, "variables"))
    testthat::expect_invisible(assert_picks_has(p, "values"))
  })

  it("errors when element is absent", {
    p_no_values <- picks(datasets(), variables())
    testthat::expect_error(assert_picks_has(p_no_values, "values"), "does not contain")
  })

  it("errors when x is not a picks object", {
    testthat::expect_error(assert_picks_has(list(), "datasets"), "picks")
  })
})
