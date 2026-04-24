describe("picks_srv accepts picks", {
  it("as single picks object", {
    test_data <- list(iris = iris, mtcars = mtcars)
    test_picks <- picks(datasets(choices = c("iris", "mtcars"), selected = "iris"))
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_no_error(
        picks_srv(id = "test", picks = test_picks, data = shiny::reactive(test_data))
      )
    )
  })

  it("as list of picks objects", {
    test_data <- list(iris = iris, mtcars = mtcars)
    test_picks_list <- list(
      pick1 = picks(datasets(choices = c("iris", "mtcars"), selected = "iris")),
      pick2 = picks(datasets(choices = c("iris", "mtcars"), selected = "mtcars"))
    )
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_no_error(
        picks_srv(id = "test", picks = test_picks_list, data = shiny::reactive(test_data))
      )
    )
  })

  it("accepts empty list", {
    test_data <- list(iris = iris)
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_no_error(
        picks_srv(id = "test", picks = list(), data = shiny::reactive(test_data))
      )
    )
  })

  it("doesn't accept list of non-picks", {
    test_data <- list(iris = iris)
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_error(
        picks_srv(id = "test", picks = list(a = 1, b = 2), data = shiny::reactive(test_data))
      )
    )
  })

  it("doesn't accept NULL picks", {
    test_data <- list(iris = iris)

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_error(
        picks_srv(id = "test", picks = NULL, data = shiny::reactive(test_data))
      )
    )
  })

  it("doesn't accept unnamed list of picks", {
    test_picks_list <- list(
      picks(datasets(choices = "iris")),
      picks(datasets(choices = "iris"))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_error(
        picks_srv(id = "test", picks = test_picks_list, data = shiny::reactive(test_data))
      )
    )
  })

  it("doesn't accept list of picks with duplicated names", {
    test_picks_list <- list(
      a = picks(datasets(choices = "iris")),
      a = picks(datasets(choices = "iris"))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_error(
        picks_srv(id = "test", picks = test_picks_list, data = shiny::reactive(test_data))
      )
    )
  })
})

describe("picks_srv accepts data", {
  it("as reactive (named) list", {
    test_data <- list(iris = iris)
    test_picks <- picks(datasets(choices = "iris"))

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_no_error(
        picks_srv(id = "test", picks = test_picks, data = shiny::reactive(test_data))
      )
    )
  })

  it("as reactive environment", {
    test_data <- list2env(list(iris = iris))
    test_picks <- picks(datasets(choices = "iris"))

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_no_error(
        picks_srv(id = "test", picks = test_picks, data = shiny::reactive(test_data))
      )
    )
  })

  it("doesn't accept non-reactive list/environment/teal_data", {
    test_picks <- picks(datasets(choices = "iris"))

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = {
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = iris),
          "reactive"
        )
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = list(iris = iris)),
          "reactive"
        )
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = teal.data::teal_data(iris = iris)),
          "reactive"
        )
      }
    )
  })

  it("doesn't accept reactive non-named-list or non-environment", {
    test_picks <- picks(datasets(choices = "iris"))

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = {
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = shiny::reactive(iris))
        )
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = shiny::reactive(letters))
        )
        expect_error(
          picks_srv(id = "test", picks = test_picks, data = shiny::reactive(list(iris)))
        )
      }
    )
  })
})

describe("picks_srv return a named list of reactive picks", {
  it("each list element is reactiveVal", {
    test_picks_list <- list(
      pick1 = picks(datasets(choices = c("iris", "mtcars"), selected = "iris")),
      pick2 = picks(datasets(choices = c("iris", "mtcars"), selected = "mtcars"))
    )
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = checkmate::expect_list(
        picks_srv(id = "test", picks = test_picks_list, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
        types = "reactiveVal",
        names = "unique"
      )
    )
  })

  it("list is named as pick argument", {
    test_picks_list <- list(
      pick1 = picks(datasets(choices = c("iris", "mtcars"), selected = "iris")),
      pick2 = picks(datasets(choices = c("iris", "mtcars"), selected = "mtcars"))
    )
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = expect_named(
        picks_srv(id = "test", picks = test_picks_list, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
        c("pick1", "pick2")
      )
    )
  })

  it("each list element is reactiveVal containing picks", {
    test_picks_list <- list(
      pick1 = picks(datasets(choices = c("iris", "mtcars"), selected = "iris")),
      pick2 = picks(datasets(choices = c("iris", "mtcars"), selected = "mtcars"))
    )
    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = {
        out <- picks_srv(
          id = "test", picks = test_picks_list, data = shiny::reactive(list(iris = iris, mtcars = mtcars))
        )
        checkmate::expect_list(out, "reactiveVal")
        lapply(out, function(x) checkmate::assert_class(shiny::isolate(x()), "picks"))
      }
    )
  })
})

describe("picks_srv resolves datasets", {
  it("provided non-delayed datasets are adjusted to possible datanames", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars", notexisting = "notexisting"), selected = "mtcars")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars))),
      expr = {
        test_picks$datasets$choices <- c(mtcars = "mtcars")
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("datasets(<tidyselect>) are resolved on init", {
    test_picks <- picks(
      datasets(choices = tidyselect::everything(), selected = tidyselect::last_col())
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars, a = "a"))),
      expr = {
        expect_identical(
          picks_resolved(),
          picks(
            datasets(choices = c(iris = "iris", mtcars = "mtcars", a = "a"), selected = "a")
          )
        )
      }
    )
  })

  it("datasets(<predicate>) are resolved on init", {
    # tidyselect::where is based on the columns values - unlike other functions which utilized column-names vector
    test_picks <- picks(datasets(choices = is.data.frame, selected = 1L))
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars, a = "a"))),
      expr = {
        expect_identical(
          picks_resolved(),
          picks(
            datasets(choices = c(iris = "iris", mtcars = "mtcars"), selected = "iris")
          )
        )
      }
    )
  })
})

describe("picks_srv resolves variables", {
  it("variables(<eager>) are adjusted to possible column names", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
      variables(choices = c(mpg = "mpg", cyl = "cyl", inexisting = "inexisting"), selected = c("mpg", "inexisting"))
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars))),
      expr = {
        test_picks$variables$choices <- c(mpg = "mpg", cyl = "cyl")
        test_picks$variables$selected <- "mpg"
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("variables(<tidyselect>) are resolved on init", {
    test_picks <- picks(
      datasets(choices = "mtcars", selected = "mtcars"),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        expect_identical(
          picks_resolved(),
          picks(
            datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
            variables(choices = setNames(colnames(mtcars), colnames(mtcars)), selected = "mpg")
          )
        )
      }
    )
  })

  it("variables(<predicate>) are resolved on init", {
    # tidyselect::where is based on the columns values - unlike other functions which utilized column-names vector
    test_picks <- picks(
      datasets(choices = "mtcars", selected = "mtcars"),
      variables(choices = function(x) mean(x) > 20, selected = 1L)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        expect_identical(
          picks_resolved(),
          picks(
            datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
            variables(choices = c(mpg = "mpg", disp = "disp", hp = "hp"), selected = "mpg")
          )
        )
      }
    )
  })

  it("variables() are nullified with warning when selected dataset has no columns", {
    # tidyselect::where is based on the columns values - unlike other functions which utilized column-names vector
    test_picks <- picks(
      datasets(choices = c(test = "test"), selected = "test"),
      variables(choices = "doesn't matter", selected = "doesn't matter")
    )
    expect_warning(
      shiny::testServer(
        picks_srv,
        args = list(id = "test", picks = test_picks, data = shiny::reactive(list(test = data.frame()))),
        expr = {
          test_picks$variables$choices <- NULL
          test_picks$variables$selected <- NULL
          expect_identical(picks_resolved(), test_picks)
        }
      ),
      "Selected dataset has no columns"
    )
  })
})

describe("picks_srv resolves values", {
  it("values(<predicate>) are resolved on init", {
    test_picks <- picks(
      datasets(choices = "mtcars", selected = "mtcars"),
      variables(choices = "mpg", selected = "mpg"),
      values(choices = function(x) x > 20)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        expect_identical(
          picks_resolved(),
          picks(
            datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
            variables(choices = c(mpg = "mpg"), selected = "mpg"),
            values(
              choices = unique(mtcars$mpg[mtcars$mpg > 20]),
              selected = unique(mtcars$mpg[mtcars$mpg > 20])
            )
          )
        )
      }
    )
  })

  it("values(<character>) are adjusted to possible levels", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Species = "Species"), selected = "Species"),
      values(
        choices = c(setosa = "setosa", versicolor = "versicolor", inexisting = "inexisting"),
        selected = c("setosa", "versicolor", "inexisting")
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        test_picks$values$choices <- c(setosa = "setosa", versicolor = "versicolor")
        test_picks$values$selected <- c("setosa", "versicolor")
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("values(<numeric>) are adjusted to possible range", {
    skip("range works different")
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(
        choices = c(min(iris$Sepal.Length) - 1, max(iris$Sepal.Length) + 1),
        selected = c(min(iris$Sepal.Length) - 1, max(iris$Sepal.Length) + 1)
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        test_picks$values$choices <- range(iris$Sepal.Length)
        test_picks$values$selected <- range(iris$Sepal.Length)
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("values(<range>) are not preserved when related data lacks finite values", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(choices = ranged(1, 10), selected = ranged(1, 10))
    )
    iris$Sepal.Length <- NA_real_
    expect_warning(
      shiny::testServer(
        picks_srv,
        args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
        expr = {
          expect_null(picks_resolved()$values$choices)
        }
      )
    )
  })

  it("values(<predicate>) are emptied (with warning) when data returns infinite", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(function(x) !is.finite(x))
    )
    iris$Sepal.Length[1] <- Inf

    expect_warning(
      shiny::testServer(
        picks_srv,
        args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
        expr = {
          test_picks$values$choices <- NULL
          test_picks$values$selected <- NULL
          expect_identical(picks_resolved(), test_picks)
        }
      ),
      "Emptying choices..."
    )
  })

  it("values(<predicate>) are set to delayed range when data-range returns infinite", {
    skip("range works different")
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(function(x) is.finite(x))
    )
    iris$Sepal.Length[1] <- Inf
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        test_picks$values$choices <- range(iris$Sepal.Length[-1])
        test_picks$values$selected <- range(iris$Sepal.Length[-1])
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("values(<predicate>) are set to data-range when predicate doesn't match anything", {
    skip("range works different")
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(function(x) FALSE)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        test_picks$values$choices <- range(iris$Sepal.Length)
        test_picks$values$selected <- range(iris$Sepal.Length)
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("values(<character>) are set to data-range when column is numeric", {
    skip("range works different")
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Sepal.Length = "Sepal.Length"), selected = "Sepal.Length"),
      values(c("5.1", "4.9"))
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        test_picks$values$choices <- range(iris$Sepal.Length)
        test_picks$values$selected <- range(iris$Sepal.Length)
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("values(<numeric>) are emptied with warning when column is not numeric", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = c(Species = "Species"), selected = "Species"),
      values(choices = c(1, 10), selected = c(1, 10))
    )

    expect_warning(
      shiny::testServer(
        picks_srv,
        args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
        expr = {
          test_picks$values$choices <- NULL
          test_picks$values$selected <- NULL
          expect_identical(picks_resolved(), test_picks)
        }
      )
    )
  })

  it("values() on multiple columns are resolved to be concatenated choices", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
      variables(choices = c(vs = "mpg", cyl = "cyl"), selected = c("mpg", "cyl")),
      values()
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars))),
      expr = {
        test_picks$values$choices <- unique(paste(mtcars$mpg, mtcars$cyl, sep = ", "))
        test_picks$values$selected <- unique(paste(mtcars$mpg, mtcars$cyl, sep = ", "))
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })
})

describe("picks_srv resolves picks", {
  it("non-delayed-picks are returned unchanged", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
      variables(choices = setNames(colnames(mtcars), colnames(mtcars)), selected = "mpg")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars))),
      expr = {
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("named non-delayed-picks preserve names", {
    test_picks <- picks(
      datasets(choices = c(dataset = "iris"), selected = "iris"),
      variables(choices = setNames(colnames(iris), letters[1:5]), selected = "Species")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("non-delayed-picks with values are returned unchanged if within a possible choices", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars"), selected = "mtcars"),
      variables(choices = setNames(colnames(mtcars), colnames(mtcars)), selected = "mpg"),
      values(choices = c(10.4, 33.9), selected = c(10.4, 33.9))
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars))),
      expr = {
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("pick elements are resolved sequentially", {
    test_picks <- picks(
      datasets(choices = tidyselect::where(is.data.frame), selected = 1L),
      variables(choices = tidyselect::everything(), selected = 1L),
      values(choices = function(x) x > 5)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        suppressWarnings(
          picks_expected <- picks(
            datasets(choices = c(iris = "iris", mtcars = "mtcars"), selected = "iris"),
            variables(choices = setNames(colnames(iris), colnames(iris)), selected = "Sepal.Length"),
            values(
              choices = unique(iris$Sepal.Length[iris$Sepal.Length > 5]),
              selected = unique(iris$Sepal.Length[iris$Sepal.Length > 5])
            )
          )
        )
        expect_identical(picks_resolved(), picks_expected)
      }
    )
  })

  it("pick elements are nullified if <previous>$selected=NULL", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = setNames(colnames(iris), colnames(iris)), selected = NULL),
      values(choices = function(x) x > 5)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        test_picks$variables$selected <- NULL
        test_picks$values$choices <- NULL
        test_picks$values$selected <- NULL
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("picks with multiple=FALSE defaults to single value even if multiple values provided", {
    test_picks <- picks(
      datasets(choices = c(iris = "iris"), selected = "iris"),
      variables(choices = setNames(colnames(iris), colnames(iris)), selected = colnames(iris), multiple = FALSE)
    )
    expect_warning(
      shiny::testServer(
        picks_srv,
        args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris))),
        expr = {
          test_picks$variables$selected <- test_picks$variables$selected[1]
          expect_identical(picks_resolved(), test_picks)
        }
      ),
      "`multiple` has been set to `FALSE`"
    )
  })

  it("picks converted from des with variable_choices are resolved", {
    test_picks <- as.picks(
      teal.transform::data_extract_spec(
        dataname = "iris",
        teal.transform::select_spec(
          choices = teal.transform::variable_choices("iris"),
          selected = teal.transform::first_choice()
        )
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        suppressWarnings(
          picks_expected <- picks(
            datasets(choices = c(iris = "iris"), selected = "iris"),
            variables(choices = setNames(colnames(iris), colnames(iris)), selected = "Sepal.Length")
          )
        )
        expect_identical(picks_resolved(), picks_expected)
      }
    )
  })

  it("picks converted from teal.transform::variable_choices(fun) are resolved", {
    test_picks <- as.picks(
      teal.transform::data_extract_spec(
        dataname = "iris",
        teal.transform::select_spec(
          choices = teal.transform::variable_choices("iris", function(data) {
            names(Filter(is.numeric, data))
          }),
          selected = teal.transform::first_choice()
        )
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "id", picks = test_picks, data = shiny::reactive(list(iris = iris, mtcars = mtcars))),
      expr = {
        suppressWarnings(
          picks_expected <- picks(
            datasets(choices = c(iris = "iris"), selected = "iris"),
            variables(choices = setNames(colnames(iris)[-5], colnames(iris)[-5]), selected = "Sepal.Length")
          )
        )
        expect_identical(picks_resolved(), picks_expected)
      }
    )
  })
})


describe("picks_srv resolves picks interactively", {
  it("opening and closing the picks don't resolve it again", {
    test_picks <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = tidyselect::everything(), selected = c(1L, 2L, 3L), multiple = TRUE)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        original_selected <- picks_resolved()$variables$selected
        session$setInputs("variables-selected_open" = TRUE)
        session$setInputs("variables-selected" = original_selected)
        expect_no_message(session$setInputs("variables-selected_open" = FALSE))
        session$flushReact()
        expect_identical(picks_resolved()$variables$selected, original_selected)
      }
    )
  })

  it("change of dataset-input resolves variables", {
    test_picks <- picks(
      datasets(choices = c(mtcars = "mtcars", iris = "iris"), selected = "mtcars"),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        session$setInputs(`datasets-selected` = "iris")
        session$setInputs(`datasets-selected_open` = FALSE) # close dropdown to trigger
        test_picks$datasets$selected <- "iris"
        test_picks$variables$choices <- setNames(colnames(iris), colnames(iris))
        test_picks$variables$selected <- "Sepal.Length"
        expect_identical(picks_resolved(), test_picks)
      }
    )
  })

  it("reversing input$selected order does not update picks_resolved", {
    test_picks <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = tidyselect::everything(), selected = c(1L, 2L, 3L), multiple = TRUE)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        original_selected <- picks_resolved()$variables$selected
        session$setInputs("variables-selected_open" = TRUE)
        session$setInputs("variables-selected" = rev(original_selected))
        expect_no_message(session$setInputs("variables-selected_open" = FALSE))
        session$flushReact()
        expect_identical(picks_resolved()$variables$selected, rev(original_selected))
      }
    )
  })

  it("current datasets-choices/selected are produced in picker inputs", {
    test_picks <- picks(
      datasets(choices = c("mtcars", "iris"), selected = "iris")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        choices_value <- rvest::html_attr(rvest::html_nodes(html, "option"), "value")
        selected_value <- rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value")
        expect_identical(choices_value, c("mtcars", "iris"))
        expect_identical(selected_value, "iris")
      }
    )
  })

  it("custom choices label set in picks is displayed in a picker input", {
    test_picks <- picks(
      datasets(choices = c(`mtcars dataset` = "mtcars", `iris dataset` = "iris"), selected = "iris")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        choices_label <- rvest::html_text(rvest::html_nodes(html, "option"))
        expect_identical(choices_label, c("mtcars dataset", "iris dataset"))
      }
    )
  })

  it("custom choices label set in data is displayed in a picker input", {
    test_picks <- picks(
      datasets(choices = c("mtcars", "iris"), selected = "iris")
    )
    attr(mtcars, "label") <- "mtcars dataset"
    attr(iris, "label") <- "iris dataset"
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        choices_label <- rvest::html_text(rvest::html_nodes(html, "option"))
        expect_identical(choices_label, c("mtcars dataset", "iris dataset"))
      }
    )
  })

  it("custom choices label set in picks has priority over data label is displayed in a picker input", {
    test_picks <- picks(
      datasets(choices = c(`mtcars picks` = "mtcars", `iris picks` = "iris"), selected = "iris")
    )
    attr(mtcars, "label") <- "mtcars label"
    attr(iris, "label") <- "iris label"
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        choices_label <- rvest::html_text(rvest::html_nodes(html, "option"))
        expect_identical(choices_label, c("mtcars picks", "iris picks"))
      }
    )
  })

  it("picker input choices produces class-specific-icons for variable", {
    test_dataset <- data.frame(
      col_numeric = c(1.5, 2.5, 3.5),
      col_integer = 1L:3L,
      col_logical = c(TRUE, FALSE, TRUE),
      col_character = c("a", "b", "c"),
      col_factor = factor(c("x", "y", "z")),
      col_date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
      col_datetime = as.POSIXct(c("2024-01-01 12:00:00", "2024-01-02 12:00:00", "2024-01-03 12:00:00"))
    )

    test_picks <- picks(
      datasets(choices = "test", selected = "test"),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(test = test_dataset))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        icons <- gsub(
          "^.+fa-((\\w|-)+).+$", "\\1",
          rvest::html_attr(rvest::html_nodes(html, "option"), "data-content")
        )

        expect_identical(
          icons, c("arrow-up-1-9", "arrow-up-1-9", "pause", "font", "chart-bar", "calendar", "calendar")
        )
      }
    )
  })

  it("picker input choices produces class-specific-icons for datasets", {
    skip("todo")
  })

  it("switching dataset-input changes variables-input", {
    test_picks <- picks(
      datasets(choices = c("mtcars", "iris"), selected = "iris"),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value"), "Sepal.Length"
        )
        session$setInputs(`datasets-selected` = "mtcars")
        session$setInputs(`datasets-selected_open` = FALSE)
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value"), "mpg"
        )
      }
    )
  })

  it("Setting numeric variable resolves values to be a slider input with variable range", {
    skip("range works different")
    test_picks <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = "Sepal.Length", selected = "Sepal.Length"),
      values(choices = function(x) !is.na(x), selected = function(x) !is.na(x))
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["values-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "input[type='number']"), "value"),
          as.character(range(iris$Sepal.Length))
        )
      }
    )
  })

  it("switching variables-input changes values-input", {
    test_picks <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = c("Sepal.Length", "Species"), selected = "Species"),
      values(choices = function(x) !is.na(x), selected = function(x) !is.na(x))
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        html <- rvest::read_html(as.character(session$output[["values-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value"),
          c("setosa", "versicolor", "virginica")
        )
        session$setInputs(`variables-selected` = "Sepal.Length")
        session$setInputs(`variables-selected_open` = FALSE)
        html <- rvest::read_html(as.character(session$output[["values-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value"),
          as.character(unique(iris$Sepal.Length))
        )
      }
    )
  })

  it("changing picks_resolved doesn't change picker input", {
    test_picks <- picks(
      datasets(choices = c("iris", "mtcars"), selected = "iris")
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        current_picks <- picks_resolved()
        current_picks$datasets$selected <- "mtcars"
        picks_resolved(current_picks)
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected='selected']"), "value"),
          "iris"
        )
      }
    )
  })

  it("adding a dataset to data adds new choice to dataset choices", {
    skip("todo: tests can't trigger data()")
    test_picks <- picks(
      datasets(choices = tidyselect::everything(), selected = 1L),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    reactive_data <- reactiveVal(
      list(
        iris = iris,
        mtcars = mtcars
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = reactive_data),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        expect_identical(rvest::html_attr(rvest::html_nodes(html, "option"), "value"), c("iris", "mtcars"))
        reactive_data(
          list(
            a = data.frame(a = 1:10, b = letters[1:10]),
            iris = iris,
            mtcars = mtcars
          )
        )

        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option"), "value"),
          c("a", "iris", "mtcars")
        )
      }
    )
  })

  it("adding a column to data adds new choice to variables-choices", {
    skip("todo: tests can't trigger data()")
    test_picks <- picks(
      datasets(choices = tidyselect::everything(), selected = 1L),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    reactive_data <- reactiveVal(
      list(
        iris = iris,
        mtcars = mtcars
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = reactive_data),
      expr = {
        reactive_data(
          list(
            iris = transform(iris, new = 1:150),
            mtcars = mtcars
          )
        )
        session$flushReact()
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option"), "value"),
          c("a", "mtcars")
        )
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected = 'selected']"), "value"),
          "iris"
        )
      }
    )
  })

  it("removing a (selected) dataset from data removes choice from dataset choices and from selection with warning", {
    test_picks <- picks(
      datasets(choices = tidyselect::everything(), selected = 1L),
      variables(choices = tidyselect::everything(), selected = 1L)
    )
    reactive_data <- reactiveVal(
      list(
        iris = iris,
        mtcars = mtcars
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = reactive_data),
      expr = {
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        expect_identical(rvest::html_attr(rvest::html_nodes(html, "option"), "value"), c("iris", "mtcars"))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected = 'selected']"), "value"),
          "iris"
        )
        reactive_data(
          list(
            a = data.frame(a = 1:10, b = letters[1:10]),
            mtcars = mtcars
          )
        )

        expect_warning(session$flushReact())
        html <- rvest::read_html(as.character(session$output[["datasets-selected_container"]]$html))
        expect_identical(rvest::html_attr(rvest::html_nodes(html, "option"), "value"), c("a", "mtcars"))
        expect_length(
          rvest::html_attr(rvest::html_nodes(html, "option[selected = 'selected']"), "value"),
          0
        )
      }
    )
  })

  it("removing a (selected) variable from data removes choice from dataset choices and from selection", {
    test_picks <- picks(
      datasets(choices = tidyselect::everything(), selected = 1L),
      variables(choices = tidyselect::everything(), selected = tidyselect::starts_with("Sepal"), multiple = TRUE)
    )
    reactive_data <- reactiveVal(
      list(
        iris = iris,
        mtcars = mtcars
      )
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = reactive_data),
      expr = {
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected = 'selected']"), "value"),
          c("Sepal.Length", "Sepal.Width")
        )
        reactive_data(
          list(
            iris = iris[-1],
            mtcars = mtcars
          )
        )
        session$flushReact()
        html <- rvest::read_html(as.character(session$output[["variables-selected_container"]]$html))
        expect_identical(rvest::html_attr(rvest::html_nodes(html, "option"), "value"), colnames(iris)[-1])
        expect_identical(
          rvest::html_attr(rvest::html_nodes(html, "option[selected = 'selected']"), "value"),
          "Sepal.Width"
        )
      }
    )
  })

  it("variables(ordered=TRUE) returns input following a selection-order instead of choices-order", {
    test_picks <- picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = tidyselect::everything(), selected = 3L, multiple = TRUE, ordered = TRUE)
    )
    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(mtcars = mtcars, iris = iris))),
      expr = {
        session$setInputs(`variables-selected` = colnames(iris)[c(1L, 3L)])
        session$setInputs(`variables-selected_open` = FALSE) # close dropdown to trigger
        session$setInputs(`variables-selected` = colnames(iris)[c(1L, 2L, 3L)])
        session$setInputs(`variables-selected_open` = FALSE) # close dropdown to trigger
        session$setInputs(`variables-selected` = colnames(iris)[c(1L, 2L, 3L, 4L)])
        session$setInputs(`variables-selected_open` = FALSE) # close dropdown to trigger
        expect_identical(picks_resolved()$variables$selected, colnames(iris)[c(3L, 1L, 2L, 4L)])
      }
    )
  })

  it("changing character slider input updates picks_resolved when needed", {
    test_picks <- picks(
      datasets("iris", "iris"),
      variables(c("Species", "Sepal.Length"))
    )

    shiny::testServer(
      picks_srv,
      args = list(id = "test", picks = test_picks, data = shiny::reactive(list(iris = iris))),
      expr = {
        session$returned()
        session$setInputs(`variables-selected` = colnames(iris)[c(1L, 3L)])
        session$setInputs(`variables-selected_open` = FALSE) # close dropdown to trigger
      }
    )
  })

  it("changing numeric range in slider input updates picks_resolved")

  it("changing integer range in slider input updates picks_resolved")

  it("changing date range in slider input updates picks_resolved")

  it("changing date range in slider input updates picks_resolved")

  it("setting picks_resolved$selected outside of range adjust to the available range")
})
