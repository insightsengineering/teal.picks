testthat::describe("format.type() for datasets", {
  it("formats datasets with character choices by printing them explicitly", {
    ds <- datasets(choices = c("iris", "mtcars"), selected = "iris")
    expected <- " \033[1m<datasets>\033[0m\n   choices: iris, mtcars\n   selected: iris\n   \033[3mmultiple=FALSE, ordered=FALSE, fixed=FALSE\033[0m\n" # nolint
    testthat::expect_identical(format(ds), expected)
  })

  it("formats datasets with tidyselect choices by printing matched call's argument", {
    ds <- datasets(choices = tidyselect::everything(), selected = 1L)
    result <- format(ds)
    testthat::expect_match(result, "<datasets>")
    testthat::expect_match(result, "choices:.*everything\\(\\)")
    testthat::expect_match(result, "selected:.*1")
  })
})

testthat::describe("print.type() for variables", {
  it("prints variables with character choices by printing them explicitly", {
    vars <- variables(choices = c("a", "b", "c"), selected = c("a", "b"), multiple = TRUE)
    expected <- " \033[1m<variables>\033[0m\n   choices: a, b, c\n   selected: a, b\n   \033[3mmultiple=TRUE, ordered=FALSE, fixed=FALSE, allow-clear=TRUE\033[0m\n" # nolint
    testthat::expect_identical(format(vars), expected)
  })


  it("formats variables with ordered attribute correctly", {
    vars <- variables(choices = c("x", "y", "z"), selected = c("x", "y"), ordered = TRUE)
    result <- format(vars)
    testthat::expect_match(result, "ordered=TRUE")
  })
})

testthat::describe("format.type() for values", {
  it("formats values with character choices by printing them explicitly with their attributes", {
    vals <- values(choices = c("1", "2", "3"), selected = c("1", "2"), multiple = TRUE)
    expected <- " \033[1m<values>\033[0m\n   choices: 1, 2, 3\n   selected: 1, 2\n   \033[3mmultiple=TRUE, ordered=FALSE, fixed=FALSE\033[0m\n" # nolint
    testthat::expect_identical(format(vals), expected)
  })
})


testthat::describe("format.picks() for picks collection", {
  it("formats picks with datasets, variables and values by showing them all explicitly", {
    p <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = "a", selected = "a", multiple = FALSE),
      values(choices = c("1", "2"), selected = "1", multiple = FALSE)
    )
    expected <- paste(
      c(
        " \033[1m<picks>\033[0m",
        "   \033[1m<datasets>\033[0m:",
        "     choices: iris",
        "     selected: iris",
        "     \033[3mmultiple=FALSE, ordered=FALSE, fixed=TRUE\033[0m",
        "   \033[1m<variables>\033[0m:",
        "     choices: a",
        "     selected: a",
        "     \033[3mmultiple=FALSE, ordered=FALSE, fixed=TRUE, allow-clear=FALSE\033[0m",
        "   \033[1m<values>\033[0m:",
        "     choices: 1, 2",
        "     selected: 1",
        "     \033[3mmultiple=FALSE, ordered=FALSE, fixed=FALSE\033[0m\n"
      ),
      collapse = "\n"
    )

    testthat::expect_identical(format(p), expected)
  })
})

testthat::describe("print methods output correctly", {
  it("print.type() outputs datasets to console with class name, choices and selected", {
    ds <- datasets(choices = "iris", selected = "iris")
    testthat::expect_output(print(ds), "<datasets>")
    testthat::expect_output(print(ds), "choices:")
    testthat::expect_output(print(ds), "selected:")
  })

  it("print.picks() outputs picks to console with its class and elements", {
    p <- picks(datasets(choices = "iris"))
    testthat::expect_output(print(p), "<picks>")
    testthat::expect_output(print(p), "<datasets>")
  })

  it("print returns invisibly", {
    ds <- datasets(choices = "iris", selected = "iris")
    result <- print(ds)
    testthat::expect_identical(result, ds)
  })
})
