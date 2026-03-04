testthat::describe("picks() assertions", {
  it("fails when first element is not datasets", {
    testthat::expect_error(picks(variables()), "datasets")
  })

  it("succeeds when first element is datasets", {
    testthat::expect_no_error(picks(datasets()))
  })

  it("fails with empty input", {
    testthat::expect_error(picks())
  })

  it("fails when input is not of class 'type'", {
    testthat::expect_error(picks(list(a = 1, b = 2)))
  })

  it("fails when mixing valid and invalid types", {
    testthat::expect_error(
      picks(datasets(), list(invalid = "test"))
    )
  })

  it("fails when values exists without variables", {
    testthat::expect_error(
      picks(datasets(), values()),
      "requires variables\\(\\) before values\\(\\)"
    )
  })

  it("succeeds when values immediately follows variables", {
    testthat::expect_no_error(
      picks(datasets(), variables(), values())
    )
  })

  it("fails when values doesn't immediately follow variables", {
    testthat::expect_error(
      picks(datasets(), values(), variables())
    )
  })

  it("succeeds with only datasets and variables (no values)", {
    testthat::expect_no_error(
      picks(datasets(), variables())
    )
  })

  it("warns when element with dynamic choices is followed by element with eager choices", {
    testthat::expect_warning(
      picks(
        datasets(c("iris", "mtcars")),
        variables(c("Species"))
      ),
      "eager"
    )
  })
})

testthat::describe("picks() basic structure", {
  it("returns an object of class 'picks' and 'list'", {
    result <- picks(datasets())
    testthat::expect_s3_class(result, "picks")
    testthat::expect_type(result, "list")
  })

  it("creates a picks object with single datasets element", {
    result <- picks(datasets())
    checkmate::expect_list(result, len = 1, types = "datasets")
  })

  it("creates a picks object with datasets and variables", {
    result <- picks(datasets(), variables())
    checkmate::expect_list(result, len = 2, types = c("datasets", "variables"))
    testthat::expect_named(result, c("datasets", "variables"))
  })

  it("creates a picks object with datasets, variables and values", {
    result <- picks(datasets(), variables(), values())
    checkmate::expect_list(result, len = 3, types = c("datasets", "variables", "values"))
    testthat::expect_named(result, c("datasets", "variables", "values"))
  })

  it("ignores trailing empty arguments", {
    result <- picks(datasets(), variables(), )
    checkmate::expect_list(result, len = 2, types = c("datasets", "variables"))
  })
})

testthat::describe("datasets() basic asserts:", {
  it("datasets(choices) argument accepts character, integer, predicate function and tidyselect", {
    testthat::expect_no_error(datasets(choices = "test"))
    testthat::expect_no_error(datasets(choices = 1L))
    testthat::expect_no_error(datasets(choices = tidyselect::everything()))
    testthat::expect_no_error(datasets(choices = tidyselect::where(is.data.frame)))
    testthat::expect_no_error(datasets(choices = c(test:test, test)))
    testthat::expect_no_error(datasets(choices = tidyselect::starts_with("Petal") | tidyselect::ends_with("Width")))
    testthat::expect_no_error(datasets(choices = tidyselect::all_of(c("test", "test2"))))
    testthat::expect_error(datasets(choices = c(1.2))) # double
    testthat::expect_error(datasets(choices = c(1.0))) # integerish
    testthat::expect_error(datasets(choices = as.Date(1))) # Date
  })

  it("datasets(choices) can't be empty", {
    testthat::expect_error(datasets(choices = character(0)))
    testthat::expect_error(datasets(choices = NULL))
    testthat::expect_error(datasets(choices = list()))
  })

  it("datasets(selected) argument character(1), integer(1), predicate and tidyselect or empty", {
    testthat::expect_no_error(datasets(selected = 1L))
    testthat::expect_no_error(datasets(selected = tidyselect::everything()))
    testthat::expect_no_error(datasets(selected = function(x) TRUE))
    testthat::expect_no_error(datasets(selected = NULL))
    testthat::expect_error(datasets(choices = c("iris", "mtcars"), selected = c("iris", "mtcars")))
  })


  it("datasets(selected) must be a subset of choices", {
    testthat::expect_error(datasets(choices = c("a", "b"), selected = "c"), "subset of `choices`")
  })

  it("datasets(selected) warns if choices are delayed and selected eager", {
    testthat::expect_warning(datasets(choices = tidyselect::everything(), selected = "c"), "subset of `choices`")
    testthat::expect_warning(datasets(choices = 1L, selected = "c"), "subset of `choices`")
  })
})

testthat::describe("datasets() returns datasets", {
  it("returns an object of class 'datasets' and 'type'", {
    result <- datasets(choices = "iris")
    testthat::expect_s3_class(result, "datasets")
  })

  it("returns a list with 'choices' and 'selected' elements", {
    result <- datasets(choices = "iris")
    testthat::expect_type(result, "list")
    testthat::expect_named(result, c("choices", "selected"))
  })

  it("stores static character vector in $choices", {
    result <- datasets(choices = c("iris", "mtcars"))
    testthat::expect_equal(result$choices, c("iris", "mtcars"))
  })

  it("defaults selected to 1'st when not specified", {
    result <- datasets(choices = c("iris", "mtcars"))
    testthat::expect_s3_class(result$selected, "quosure")
    testthat::expect_equal(rlang::quo_get_expr(result$selected), 1)
  })

  it("stores custom selected value", {
    result <- datasets(choices = c("iris", "mtcars"), selected = "mtcars")
    testthat::expect_equal(result$selected, "mtcars")
  })

  it("stores integer selected value as quosure", {
    result <- datasets(choices = c("iris", "mtcars"), selected = 2L)
    testthat::expect_s3_class(result$selected, "quosure")
    testthat::expect_equal(rlang::quo_get_expr(result$selected), 2L)
  })

  it("sets fixed to TRUE when single choice", {
    testthat::expect_true(attr(datasets(choices = "test"), "fixed"))
  })
})

testthat::describe("datasets() returns quosures for delayed evaluation", {
  it("stores tidyselect::everything() as a quosure in $choices", {
    result <- datasets(choices = tidyselect::everything())
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::where() as a predicate function in $choices", {
    result <- datasets(choices = tidyselect::where(is.data.frame))
    testthat::expect_true(is.function(result$choices))
  })

  it("stores symbol range (a:b) as a quosure in $choices", {
    result <- datasets(choices = c(a:b))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores numeric range (1:5) as a quosure in $choices", {
    result <- datasets(choices = seq(1, 5))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::starts_with() as a quosure in $choices", {
    result <- datasets(choices = tidyselect::starts_with("test"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::ends_with() as a quosure in $choices", {
    result <- datasets(choices = tidyselect::ends_with("test"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores combined tidyselect expressions as a quosure in $choices", {
    result <- datasets(choices = tidyselect::starts_with("a") | tidyselect::ends_with("b"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("does not store static character vector as a quosure in $choices", {
    result <- datasets(choices = c("a", "b", "c"))
    testthat::expect_false(inherits(result$choices, "quosure"))
    testthat::expect_type(result$choices, "character")
  })
})

testthat::describe("datasets() attributes", {
  it("sets multiple attribute to FALSE (always single selection)", {
    result <- datasets(choices = c("iris", "mtcars"))
    testthat::expect_false(attr(result, "multiple"))
  })

  it("sets fixed to TRUE for single non-delayed choice", {
    result <- datasets(choices = "iris")
    testthat::expect_true(attr(result, "fixed"))
  })

  it("sets fixed to FALSE for multiple choices", {
    result <- datasets(choices = c("iris", "mtcars"))
    testthat::expect_false(attr(result, "fixed"))
  })

  it("sets fixed to FALSE for delayed choices (tidyselect)", {
    result <- datasets(choices = tidyselect::everything())
    testthat::expect_false(attr(result, "fixed"))
  })

  it("allows explicit fixed = TRUE override", {
    result <- datasets(choices = c("iris", "mtcars"), fixed = TRUE)
    testthat::expect_true(attr(result, "fixed"))
  })

  it("allows explicit fixed = FALSE override", {
    result <- datasets(choices = "iris", fixed = FALSE)
    testthat::expect_false(attr(result, "fixed"))
  })

  it("passes additional arguments via ...", {
    result <- datasets(choices = "iris", custom_attr = "test_value")
    testthat::expect_equal(attr(result, "custom_attr"), "test_value")
  })
})

testthat::describe("datasets() validation and warnings", {
  it("warns when selected is explicit and choices are delayed", {
    testthat::expect_warning(
      datasets(choices = tidyselect::everything(), selected = "iris"),
      "Setting explicit `selected` while `choices` are delayed"
    )
  })

  it("does not warn when selected is numeric and choices are delayed", {
    testthat::expect_no_warning(
      datasets(choices = tidyselect::everything(), selected = 1L)
    )
  })

  it("does not warn when both choices and selected are static", {
    testthat::expect_no_warning(
      datasets(choices = c("iris", "mtcars"), selected = "iris")
    )
  })
})

testthat::describe("datasets() integration with tidyselect helpers", {
  it("accepts tidyselect::all_of()", {
    testthat::expect_no_error(
      datasets(choices = tidyselect::all_of(c("iris", "mtcars")))
    )
  })

  it("accepts tidyselect::any_of()", {
    testthat::expect_no_error(
      datasets(choices = tidyselect::any_of(c("iris", "mtcars")))
    )
  })

  it("stores tidyselect::starts_with() as a quosure", {
    result <- datasets(choices = tidyselect::starts_with("ir"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::ends_with() as a quosure", {
    result <- datasets(choices = tidyselect::ends_with("s"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::contains() as a quosure", {
    result <- datasets(choices = tidyselect::contains("car"))
    testthat::expect_s3_class(result$choices, "quosure")
  })

  it("stores tidyselect::matches() as a quosure", {
    result <- datasets(choices = tidyselect::matches("^i"))
    testthat::expect_s3_class(result$choices, "quosure")
  })
})

testthat::describe("variables() multiple attribute", {
  it("sets multiple to FALSE for single selected value", {
    result <- variables(choices = c("a", "b", "c"), selected = "a")
    testthat::expect_false(attr(result, "multiple"))
  })

  it("sets multiple to TRUE for multiple selected values", {
    result <- variables(choices = c("a", "b", "c"), selected = c("a", "b"))
    testthat::expect_true(attr(result, "multiple"))
  })

  it("sets multiple to FALSE when explicitly specified", {
    result <- variables(choices = c("a", "b", "c"), selected = "a", multiple = FALSE)
    testthat::expect_false(attr(result, "multiple"))
  })

  it("sets multiple to TRUE when explicitly specified", {
    result <- variables(choices = c("a", "b", "c"), selected = "a", multiple = TRUE)
    testthat::expect_true(attr(result, "multiple"))
  })

  it("auto-detects multiple = TRUE from selected vector length", {
    result <- variables(choices = c("a", "b", "c", "d"), selected = c("a", "b", "c"))
    testthat::expect_true(attr(result, "multiple"))
  })

  it("auto-detects multiple = FALSE from single selected", {
    result <- variables(choices = c("a", "b", "c"), selected = "b")
    testthat::expect_false(attr(result, "multiple"))
  })

  it("defaults to NULL for tidyselect selected", {
    result <- variables(choices = c("a", "b"), selected = tidyselect::everything())
    testthat::expect_false(attr(result, "multiple"))
  })

  it("explicit multiple overrides auto-detection", {
    result <- variables(choices = c("a", "b", "c"), selected = c("a", "b"), multiple = FALSE)
    testthat::expect_false(attr(result, "multiple"))
  })
})

testthat::describe("variables() ordered attribute", {
  it("defaults to FALSE", {
    result <- variables(choices = c("a", "b", "c"))
    testthat::expect_false(attr(result, "ordered"))
  })

  it("sets ordered to TRUE when specified", {
    result <- variables(choices = c("a", "b", "c"), ordered = TRUE)
    testthat::expect_true(attr(result, "ordered"))
  })

  it("sets ordered to FALSE when explicitly specified", {
    result <- variables(choices = c("a", "b", "c"), ordered = FALSE)
    testthat::expect_false(attr(result, "ordered"))
  })
})

testthat::describe("variables() allow-clear attribute", {
  it("sets allow-clear to FALSE for single non-NULL selected", {
    result <- variables(choices = c("a", "b", "c"), selected = "a")
    testthat::expect_false(attr(result, "allow-clear"))
  })

  it("sets allow-clear to TRUE for multiple selected", {
    result <- variables(choices = c("a", "b", "c"), selected = c("a", "b"))
    testthat::expect_true(attr(result, "allow-clear"))
  })

  it("sets allow-clear to TRUE when selected is NULL", {
    result <- variables(choices = c("a", "b", "c"), selected = NULL)
    testthat::expect_true(attr(result, "allow-clear"))
  })

  it("sets allow-clear to FALSE for tidyselect selected", {
    result <- variables(choices = c("a", "b"), selected = tidyselect::everything())
    testthat::expect_false(attr(result, "allow-clear"))
  })

  it("sets allow-clear to FALSE for single numeric selected", {
    result <- variables(choices = c("a", "b", "c"), selected = 1L)
    testthat::expect_false(attr(result, "allow-clear"))
  })

  it("sets allow-clear to FALSE for multiple numeric selected (tidyselect)", {
    result <- variables(choices = c("a", "b", "c"), selected = c(1L, 2L))
    testthat::expect_false(attr(result, "allow-clear"))
  })
})

testthat::describe("variables() attribute interactions", {
  it("multiple = TRUE and ordered = TRUE work together", {
    result <- variables(
      choices = c("a", "b", "c"),
      selected = c("a", "c"),
      multiple = TRUE,
      ordered = TRUE
    )
    testthat::expect_true(attr(result, "multiple"))
    testthat::expect_true(attr(result, "ordered"))
  })

  it("multiple = FALSE and ordered = FALSE work together", {
    result <- variables(
      choices = c("a", "b", "c"),
      selected = "a",
      multiple = FALSE,
      ordered = FALSE
    )
    testthat::expect_false(attr(result, "multiple"))
    testthat::expect_false(attr(result, "ordered"))
  })

  it("allow-clear depends on multiple when selected is character", {
    result_single <- variables(choices = c("a", "b"), selected = "a", multiple = FALSE)
    result_multi <- variables(choices = c("a", "b"), selected = "a", multiple = TRUE)

    testthat::expect_false(attr(result_single, "allow-clear"))
    testthat::expect_true(attr(result_multi, "allow-clear"))
  })

  it("all three attributes can be set independently", {
    result <- variables(
      choices = c("a", "b", "c"),
      selected = c("b", "c"),
      multiple = TRUE,
      ordered = TRUE
    )
    testthat::expect_true(attr(result, "multiple"))
    testthat::expect_true(attr(result, "ordered"))
    testthat::expect_true(attr(result, "allow-clear"))
  })
})

testthat::describe("values() assertions", {
  it("values() succeeds by default", {
    testthat::expect_no_error(values())
  })

  it("values(choices) accepts predicate functions, character, numeric(2), date(2) and posixct(2). No tidyselect", {
    testthat::expect_no_error(values(choices = "test"))
    testthat::expect_no_error(values(choices = c("test", "test2")))
    testthat::expect_error(values(choices = c("test", "test")))
    testthat::expect_no_error(values(choices = c(1, 2)))
    testthat::expect_error(values(choices = 1))
    testthat::expect_error(values(choices = c(1, 2, 3)))
    testthat::expect_error(values(choices = c(-Inf, Inf)))
    testthat::expect_no_error(values(choices = as.Date(1:2)))
    testthat::expect_error(values(choices = as.Date(1)))
    testthat::expect_error(values(choices = as.Date(1:3)))
    testthat::expect_no_error(values(choices = as.POSIXct(1:2)))
    testthat::expect_error(values(choices = as.POSIXct(1)))
    testthat::expect_error(values(choices = as.POSIXct(1:3)))
    testthat::expect_no_error(values(choices = tidyselect::where(~ .x > 1))) # this is predicate, not tidyselect
    testthat::expect_no_error(values(choices = function(x) !is.na(x)))
    testthat::expect_no_error(values(choices = function(x, ...) !is.na(x)))
    testthat::expect_error(values(choices = function(x, y, ...) x > y))
    testthat::expect_error(values(choices = tidyselect::everything()))
    testthat::expect_error(values(choices = c(test:test, test)))
  })
})

testthat::describe("values() attributes", {
  it("multiple set to TRUE by default", {
    testthat::expect_true(attr(values(), "multiple"))
  })

  it("fixed=TRUE when single choice is provided", {
    testthat::expect_true(attr(values(choices = "test"), "fixed"))
  })

  it("fixed=FALSE when choices is a predicate", {
    testthat::expect_false(attr(values(choices = function(x) TRUE), "fixed"))
  })

  it("fixed=FALSE when choices length > 1", {
    testthat::expect_false(attr(values(choices = c("test", "test2")), "fixed"))
  })
})
