describe("as.picks turns select_spec to variables", {
  it("eager select_spec is convertible to variables", {
    expect_identical(
      as.picks(
        teal.transform::select_spec(choices = c("a", "b", "c"), selected = "a", multiple = TRUE, ordered = TRUE)
      ),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = "a", multiple = TRUE, ordered = TRUE)
    )
  })

  it("select_spec with selected=NULL is convertible to variables", {
    expect_identical(
      as.picks(teal.transform::select_spec(choices = c("a", "b", "c"), selected = NULL)),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = NULL)
    )
  })

  it("select_spec with multiple selected convertible to variables", {
    expect_identical(
      as.picks(teal.transform::select_spec(choices = c("a", "b", "c"), selected = c("a", "b"))),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = c("a", "b"))
    )
  })

  it("delayed select_spec is convertible to variables", {
    choices <- teal.transform::variable_choices("anything", function(data) names(Filter(is.factor, data)))
    selected <- teal.transform::first_choice()
    test <- as.picks(teal.transform::select_spec(choices = choices, selected = selected))

    expected_choices <- choices$subset
    expected_selected <- selected(choices)$subset
    class(expected_choices) <- "des-delayed"
    class(expected_selected) <- "des-delayed"
    expect_equal(
      test,
      variables(choices = expected_choices, expected_selected)
    )
  })
})

describe("as.picks doesn't convert filter_spec to picks", {
  it("throws warning with teal_tranform_filter instruction for eager filter_spec", {
    as.picks(
      teal.transform::data_extract_spec(
        dataname = "iris",
        filter = teal.transform::filter_spec(
          vars = "Species", choices = levels(iris$Species),
          selected = levels(iris$Species)
        )
      )
    ) |>
      expect_warning("`filter_spec` are not convertible to picks", fixed = TRUE)
  })
})

describe("as.picks converts choices selected to variables", {
  it("works when choices and selected are not NULL", {
    expect_s3_class(
      as.picks(teal.transform::choices_selected(
        selected = "# of patients",
        choices = c("# of patients", "# of AEs")
      )),
      "variables"
    )
  })

  it("works when choices and selected are not NULL", {
    expect_s3_class(
      as.picks(teal.transform::choices_selected(
        selected = NULL,
        choices = c("# of patients", "# of AEs")
      )),
      "variables"
    )
  })
})

describe("as.picks does not throw warning with quiet = TRUE", {
  it("does not throw warning for filter_spec when quiet = TRUE", {
    expect_null(as.picks("character", quiet = TRUE)) |>
      expect_no_warning()
    expect_null(as.picks(teal.transform::filter_spec(c("var1")), quiet = TRUE)) |>
      expect_no_warning()
  })
})