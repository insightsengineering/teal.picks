describe("check_last_level works", {
  it("checks last picks", {
    x <- list(datasets(), variables(), values())
    expect_match(check_last_level(x, "values"), "picks object")
  })

  it("checks last picks", {
    x <- picks(datasets(), variables(), values())
    expect_true(check_last_level(x, "values"))
  })

  it("returns FALSE", {
    x <- picks(datasets(), variables(), values())
    expect_match(check_last_level(x, "variables"), "in variables")
  })
})
