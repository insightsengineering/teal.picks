testthat::describe("regression tests for default", {
  it("multiple attribute in datasets", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_false(is_pick_multiple(p$datasets))
  })

  it("multiple attribute in variables", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_false(is_pick_multiple(p$variables))
  })

  it("multiple attribute in values", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_true(is_pick_multiple(p$values))
  })

  it("fixed attribute in datasets with 1 dataset", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_true(is_pick_fixed(p$datasets))
  })

  it("fixed attribute in datasets with 1 dataset", {
    suppressWarnings(p <- picks(datasets(), variables("var1"), values()))
    testthat::expect_true(is_pick_fixed(p$variables))
  })

  it("fixed attribute in datasets with 1 values", {
    suppressWarnings(p <- picks(datasets(), variables(), values("val1")))
    testthat::expect_true(is_pick_fixed(p$values))
  })

  it("fixed attribute in datasets", {
    p <- picks(datasets(), variables(), values())
    testthat::expect_false(is_pick_fixed(p$datasets))
  })

  it("fixed attribute in variables", {
    p <- picks(datasets(), variables(), values())
    testthat::expect_false(is_pick_fixed(p$variables))
  })

  it("fixed attribute in values", {
    p <- picks(datasets(), variables(), values())
    testthat::expect_false(is_pick_fixed(p$values))
  })

  it("ordered attribute in datasets", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_false(is_pick_ordered(p$datasets))
  })

  it("ordered attribute in variables", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_false(is_pick_ordered(p$variables))
  })

  it("ordered attribute in values", {
    p <- picks(datasets("iris"), variables(), values())
    testthat::expect_false(is_pick_ordered(p$values))
  })
})

testthat::describe("is_pick_multiple returns", {
  it("TRUE for variables with multiple = TRUE", {
    p <- picks(datasets("iris"), variables(multiple = TRUE))
    testthat::expect_true(is_pick_multiple(p$variables))
  })

  it("TRUE for values with multiple = TRUE", {
    p <- picks(datasets("iris"), variables(), values(multiple = TRUE))
    testthat::expect_true(is_pick_multiple(p$values))
  })

  it("FALSE for variables with multiple = FALSE", {
    p <- picks(datasets("iris"), variables(multiple = FALSE))
    testthat::expect_false(is_pick_multiple(p$variables))
  })

  it("TRUEFALSE for values with multiple = TRUE", {
    p <- picks(datasets("iris"), variables(), values(multiple = FALSE))
    testthat::expect_false(is_pick_multiple(p$values))
  })
})

testthat::describe("is_pick_fixed returns", {
  it("TRUE for variables with fixed = TRUE", {
    p <- picks(datasets("iris"), variables(fixed = TRUE))
    testthat::expect_true(is_pick_fixed(p$variables))
  })

  it("TRUE for values with fixed = TRUE", {
    p <- picks(datasets("iris"), variables(), values(fixed = TRUE))
    testthat::expect_true(is_pick_fixed(p$values))
  })

  it("FALSE for variables with fixed = FALSE", {
    p <- picks(datasets("iris"), variables(fixed = FALSE))
    testthat::expect_false(is_pick_fixed(p$variables))
  })

  it("FALSE for values with fixed = FALSE", {
    p <- picks(datasets("iris"), variables(), values(fixed = FALSE))
    testthat::expect_false(is_pick_fixed(p$values))
  })
})

testthat::describe("is_pick_ordered returns", {
  it("TRUE for variables with ordered = TRUE", {
    p <- picks(datasets("iris"), variables(ordered = TRUE))
    testthat::expect_true(is_pick_ordered(p$variables))
  })

  it("TRUE for values with ordered = TRUE", {
    p <- picks(datasets("iris"), variables(), values(ordered = TRUE))
    testthat::expect_true(is_pick_ordered(p$values))
  })

  it("FALSE for variables with ordered = FALSE", {
    p <- picks(datasets("iris"), variables(ordered = FALSE))
    testthat::expect_false(is_pick_ordered(p$variables))
  })

  it("FALSE for values with ordered = FALSE", {
    p <- picks(datasets("iris"), variables(), values(ordered = FALSE))
    testthat::expect_false(is_pick_ordered(p$values))
  })
})

testthat::describe("helpers do not accept non-pick objects", {
  it("is_pick_multiple throws error", {
    testthat::expect_error(is_pick_multiple("not a pick"), "Assertion on 'x' failed: Must inherit from class 'pick'.")
  })

  it("is_pick_fixed throws error", {
    testthat::expect_error(is_pick_fixed("not a pick"), "Assertion on 'x' failed: Must inherit from class 'pick'.")
  })

  it("is_pick_ordered throws error", {
    testthat::expect_error(is_pick_ordered("not a pick"), "Assertion on 'x' failed: Must inherit from class 'pick'.")
  })
})
