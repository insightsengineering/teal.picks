describe("ranged", {
  it("returns a function", {
    r <- ranged(0, NA)
    expect_true(is.function(r))
  })
})

describe("ranged is resolved", {
  it("works", {
    r <- ranged(20, NA)
    p <- picks(
      datasets(is.data.frame, is.data.frame),
      variables(is.numeric, 1),
      values(tidyselect::where(~ .x > 5), r)
    )
    out <- resolver(data = list("mtcars label" = mtcars), x = p)
    expect_length(out$values$selected, 2L)
  })

  it("matches expected outcome", {
    r <- ranged(20, NA)
    p <- picks(
      datasets(is.data.frame, is.data.frame),
      variables(is.numeric, 1),
      values(tidyselect::where(~ .x > 5), r)
    )
    out <- resolver(data = list("mtcars label" = mtcars), x = p)
    expect_equal(out$values$selected, range(mtcars$mpg[r(mtcars$mpg)]))
  })

})



