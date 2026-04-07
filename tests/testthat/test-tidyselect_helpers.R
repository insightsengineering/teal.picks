describe("ranged assertions", {
  it("accepts min max to be numeric", {
    expect_no_error(ranged(0L, 10L))
    expect_no_error(ranged(0.0, 10.0))
  })

  it("accepts min max to be infinite", {
    expect_no_error(ranged(-Inf, Inf))
  })

  it("doesn't accept missing values", {
    expect_error(ranged(NA, Inf))
    expect_error(ranged(-Inf, NA))
  })

  it("throws when min/max are not scalars", {
    expect_error(ranged(c(1, 2), Inf))
    expect_error(ranged(-Inf, c(1, 2)))
  })

  it("doesn't accept min to be larger than max", {
    expect_error(ranged(1, 0))
  })

  it("returns a function of x and ...", {
    out <- ranged(0, 10)
    expect_true(is.function(out))
    expect_identical(names(formals(out)), "x")
  })
})

describe("ranged when resolved", {
  it("resolved choices/selected have a class ranged", {
    picks_unresolved <- picks(
      datasets(choices = "df", selected = "df"),
      variables(choices = "a", selected = "a"),
      values(choices = ranged(2, 9), selected = ranged(4L, 6L))
    )
    out <- resolver(data = list(df = data.frame(a = seq_len(10))), x = picks_unresolved)
    expect_s3_class(out$values$choices, "ranged")
    expect_s3_class(out$values$selected, "ranged")
  })

  it("resolved choices contains original values which match specified range", {
    picks_unresolved <- picks(
      datasets(choices = "df", selected = "df"),
      variables(choices = "a", selected = "a"),
      values(choices = ranged(2, 9), selected = ranged(4L, 6L))
    )
    out <- resolver(data = list(df = data.frame(a = seq_len(10))), x = picks_unresolved)
    expect_identical(unclass(out$values$choices), seq(2, 9))
  })

  it("returns selected range containing values from vector based on the specified range", {
    picks_unresolved <- picks(
      datasets(choices = "df", selected = "df"),
      variables(choices = "a", selected = "a"),
      values(choices = ranged(), selected = ranged(4L, 6L))
    )
    out <- resolver(data = list(df = data.frame(a = seq_len(10))), x = picks_unresolved)
    expect_identical(unclass(out$values$selected), c(4L, 6L))
  })

  it("returns selected range containing shrinked range to existing range-values", {
    picks_unresolved <- picks(
      datasets(choices = "df", selected = "df"),
      variables(choices = "a", selected = "a"),
      values(choices = ranged(), selected = ranged(4, 6))
    )
    out <- resolver(data = list(df = data.frame(a = c(1, 2, 4.3, 5.7, 6.00001))), x = picks_unresolved)
    expect_identical(unclass(out$values$selected), c(4.3, 5.7))
  })

  it("fails when range is outside any value", {
    picks_unresolved <- picks(
      datasets(choices = "df", selected = "df"),
      variables(choices = "a", selected = "a"),
      values(choices = ranged(7, 10))
    )
    expect_warning(resolver(data = list(df = data.frame(a = c(1, 2, 4.3, 5.7, 6.00001))), x = picks_unresolved), "are subset of")
  })
})
