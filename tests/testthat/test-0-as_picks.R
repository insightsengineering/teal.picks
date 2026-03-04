testthat::describe("as.picks turns select_spec to variables", {
  testthat::it("eager select_spec is convertible to variables", {
    testthat::expect_identical(
      as.picks(select_spec(choices = c("a", "b", "c"), selected = "a", multiple = TRUE, ordered = TRUE)),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = "a", multiple = TRUE, ordered = TRUE)
    )
  })

  testthat::it("select_spec with selected=NULL is convertible to variables", {
    testthat::expect_identical(
      as.picks(select_spec(choices = c("a", "b", "c"), selected = NULL)),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = NULL)
    )
  })

  testthat::it("select_spec with multiple selected convertible to variables", {
    testthat::expect_identical(
      as.picks(select_spec(choices = c("a", "b", "c"), selected = c("a", "b"))),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = c("a", "b"))
    )
  })

  testthat::it("delayed select_spec is convertible to variables", {
    choices <- variable_choices("anything", function(data) names(Filter(is.factor, data)))
    selected <- first_choice()
    test <- as.picks(select_spec(choices = choices, selected = selected))

    expected_choices <- choices$subset
    expected_selected <- selected(choices)$subset
    class(expected_choices) <- "des-delayed"
    class(expected_selected) <- "des-delayed"
    testthat::expect_equal(
      test,
      variables(choices = expected_choices, expected_selected)
    )
  })
})


testthat::describe("as.picks doesn't convert filter_spec to picks", {
  testthat::it("throws warning with teal_tranform_filter instruction for eager filter_spec", {
    testthat::expect_warning(
      as.picks(
        data_extract_spec(
          dataname = "iris",
          filter = filter_spec(vars = "Species", choices = levels(iris$Species), selected = levels(iris$Species)),
        )
      )
    )
  })
})
