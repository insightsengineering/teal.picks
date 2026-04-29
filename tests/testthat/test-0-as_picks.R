describe("as.picks turns select_spec to variables", {
  it("eager select_spec is convertible to variables", {
    expect_identical(
      as.picks(
        teal.transform::select_spec(
          choices = c("a", "b", "c"),
          selected = "a",
          multiple = TRUE,
          ordered = TRUE
        )
      ),
      variables(
        choices = c(a = "a", b = "b", c = "c"),
        selected = "a",
        multiple = TRUE,
        ordered = TRUE
      )
    )
  })

  it("select_spec with selected=NULL is convertible to variables", {
    expect_identical(
      as.picks(teal.transform::select_spec(
        choices = c("a", "b", "c"),
        selected = NULL
      )),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = NULL)
    )
  })

  it("select_spec with multiple selected convertible to variables", {
    expect_identical(
      as.picks(teal.transform::select_spec(
        choices = c("a", "b", "c"),
        selected = c("a", "b")
      )),
      variables(choices = c(a = "a", b = "b", c = "c"), selected = c("a", "b"))
    )
  })

  it("delayed select_spec is convertible to variables", {
    choices <- teal.transform::variable_choices("anything", function(data) {
      names(Filter(is.factor, data))
    })
    selected <- teal.transform::first_choice()
    test <- as.picks(teal.transform::select_spec(
      choices = choices,
      selected = selected
    ))

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
  it("throws warning with teal_transform_filter instruction for eager filter_spec", {
    as.picks(
      teal.transform::data_extract_spec(
        dataname = "iris",
        filter = teal.transform::filter_spec(
          vars = "Species",
          choices = levels(iris$Species),
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
  it("with non-supporter base types", {
    expect_null(as.picks("character", quiet = TRUE)) |>
      expect_no_warning()
  })
  it("with filterspect", {
    expect_null(as.picks(
      teal.transform::filter_spec(c("var1")),
      quiet = TRUE
    )) |>
      expect_no_warning()
  })
  it("with data-extract-spec", {
    expect_s3_class(
      as.picks(
        teal.transform::data_extract_spec(
          dataname = "iris",
          filter = teal.transform::filter_spec(
            vars = "Species",
            choices = levels(iris$Species),
            selected = levels(iris$Species)
          )
        ),
        quiet = TRUE
      ),
      "picks"
    ) |>
      expect_no_warning()
  })
  it("list of filter specs", {
    checkmate::expect_list(
      as.picks(
        list(
          teal.transform::filter_spec(c("var1")),
          teal.transform::filter_spec(c("var2"))
        ),
        quiet = TRUE
      ),
      len = 0
    ) |>
      expect_no_warning()
  })
})

describe("as.picks throws warning with quiet = TRUE", {
  it("throws warning if class is not within supported classes", {
    my_random_class <- matrix()
    class(my_random_class) <- "random"
    expect_warning(
      as.picks(my_random_class),
      "'random' are not convertible to picks"
    )
  })
})

describe("tests for teal_transform_filter", {
  it("returns error if argument is not from the expected class", {
    expect_error(teal_transform_filter(matrix(), "Assertion"))
  })

  mock_transform_module <- teal_transform_filter(
    teal.transform::data_extract_spec(
      dataname = "iris",
      filter = teal.transform::filter_spec(
        vars = "Species",
        choices = c("setosa", "versicolor", "virginica"),
        selected = c("setosa", "versicolor")
      )
    )
  )

  it("creates a module of the expected class", {
    expect_s3_class(mock_transform_module[[1]], "teal_transform_module")
  })

  it("creates a ui of the expected class", {
    expect_s3_class(mock_transform_module[[1]]$ui("test"), "shiny.tag")
  })

  it("throws a warning if choices is not of valid class", {
    expect_warning(
      teal_transform_filter(
        teal.transform::data_extract_spec(
          dataname = "iris",
          filter = teal.transform::filter_spec(
            vars = "Species",
            choices = teal.transform::value_choices("iris", "Species")
          )
        )
      ),
      "teal.transform::filter_spec(choices) doesn't support",
      fixed = TRUE
    )
  })

  it("server filters iris to selected Species values", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))

    iris_data <- within(teal.data::teal_data(), {
      iris <- iris
    })

    shiny::testServer(
      mock_transform_module[[1]]$server,
      args = list(id = "test", data = shiny::reactive(iris_data)),
      expr = {
        result <- session$returned()
        expect_s4_class(result, "teal_data")
        expect_true(all(result[["iris"]]$Species %in% c("setosa", "versicolor")))
        expect_false("virginica" %in% result[["iris"]]$Species)
      }
    )
  })
})
