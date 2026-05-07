make_test_picks <- function() {
  list(
    iris_pick = picks(
      datasets(choices = "iris", selected = "iris"),
      variables(choices = "Sepal.Length", selected = "Sepal.Length")
    )
  )
}

call_ui <- function(module, id = "test") {
  do.call(module$ui, c(list(id = id), module$ui_args))
}

testthat::describe("tm_merge", {
  it("returns a teal_module", {
    result <- tm_merge(picks = make_test_picks())
    testthat::expect_s3_class(result, "teal_module")
  })

  it("returns a module with the default label", {
    result <- tm_merge(picks = make_test_picks())
    testthat::expect_identical(result$label, "merge-module")
  })

  it("returns a module with a custom label", {
    result <- tm_merge(label = "my-merge", picks = make_test_picks())
    testthat::expect_identical(result$label, "my-merge")
  })

  it("returns a module with picks passed to ui_args", {
    test_picks <- make_test_picks()
    result <- tm_merge(picks = test_picks)
    testthat::expect_identical(result$ui_args$picks, test_picks)
  })

  it("returns a module with picks passed to server_args", {
    test_picks <- make_test_picks()
    result <- tm_merge(picks = test_picks)
    testthat::expect_identical(result$server_args$picks, test_picks)
  })

  it("returns a module with empty transformators by default", {
    result <- tm_merge(picks = make_test_picks())
    testthat::expect_identical(result$transformators, list())
  })

  it("returns a module with custom transformators when provided", {
    dummy_transformator <- list(
      teal::teal_transform_module(
        label = "t",
        ui = function(id) NULL,
        server = function(id, data) data
      )
    )
    result <- tm_merge(
      picks = make_test_picks(),
      transformators = dummy_transformator
    )
    testthat::expect_identical(result$transformators, dummy_transformator)
  })
})

testthat::describe("tm_merge server", {
  make_test_teal_data <- function() {
    within(teal.data::teal_data(), iris <- iris)
  }

  it("initializes without error", {
    test_picks <- make_test_picks()
    data <- make_test_teal_data()
    testthat::expect_no_error(
      shiny::testServer(
        tm_merge(picks = test_picks)$server,
        args = list(data = shiny::reactive(data), picks = test_picks),
        expr = {}
      )
    )
  })

  it("output$mapped renders YAML containing the selected variable names", {
    test_picks <- make_test_picks()
    data <- make_test_teal_data()
    shiny::testServer(
      tm_merge(picks = test_picks)$server,
      args = list(data = shiny::reactive(data), picks = test_picks),
      expr = {
        testthat::expect_true(grepl("Sepal.Length", session$output$mapped, fixed = TRUE))
      }
    )
  })

  it("output$src contains the selected variable name", {
    test_picks <- make_test_picks()
    data <- make_test_teal_data()
    shiny::testServer(
      tm_merge(picks = test_picks)$server,
      args = list(data = shiny::reactive(data), picks = test_picks),
      expr = {
        testthat::expect_true(
          grepl("Sepal.Length", session$output$src, fixed = TRUE)
        )
      }
    )
  })

  it("output$table_merged renders an HTML table containing selected variables", {
    test_picks <- make_test_picks()
    data <- make_test_teal_data()
    shiny::testServer(
      tm_merge(picks = test_picks)$server,
      args = list(data = shiny::reactive(data), picks = test_picks),
      expr = {
        testthat::expect_true(grepl("Sepal.Length", session$output$table_merged, fixed = TRUE))
      }
    )
  })

  it("server handles multiple picks from separate datasets with join keys", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
      adae <- data.frame(studyid = "A", usubjid = c("1", "2"), AVAL = c(1.5, 2.5))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid")),
      teal.data::join_key("adae", "adae", c("studyid", "usubjid")),
      teal.data::join_key("adsl", "adae", c("studyid", "usubjid"))
    )
    test_picks <- list(
      adsl_pick = picks(datasets("adsl", "adsl"), variables("age", "age")),
      adae_pick = picks(datasets("adae", "adae"), variables("AVAL", "AVAL"))
    )
    shiny::testServer(
      tm_merge(picks = test_picks)$server,
      args = list(data = shiny::reactive(data), picks = test_picks),
      expr = {
        result <- session$returned()
        anl <- result[["anl"]]
        testthat::expect_s3_class(anl, "data.frame")
        testthat::expect_true("age" %in% names(anl))
        testthat::expect_true("AVAL" %in% names(anl))
        testthat::expect_equal(nrow(anl), 2L)
        testthat::expect_equal(sort(anl$age), c(30, 40))
        testthat::expect_equal(sort(anl$AVAL), c(1.5, 2.5))
      }
    )
  })
})

testthat::describe("tm_merge ui", {
  it("returns a shiny tag", {
    ui <- call_ui(tm_merge(picks = make_test_picks()))
    checkmate::expect_multi_class(ui, c("shiny.tag", "shiny.tag.list"))
  })

  it("renders one panel per pick", {
    test_picks <- list(
      sepal_pick = picks(
        datasets("iris", "iris"),
        variables("Sepal.Length", "Sepal.Length")
      ),
      species_pick = picks(
        datasets("iris", "iris"),
        variables("Species", "Species")
      )
    )
    ui <- call_ui(tm_merge(picks = test_picks))
    page <- rvest::read_html(as.character(ui))
    testthat::expect_length(rvest::html_elements(page, ".col-auto"), 2L)
  })

  it("labels each panel with the pick name", {
    test_picks <- list(
      sepal_pick = picks(
        datasets("iris", "iris"),
        variables("Sepal.Length", "Sepal.Length")
      ),
      species_pick = picks(
        datasets("iris", "iris"),
        variables("Species", "Species")
      )
    )
    ui <- call_ui(tm_merge(picks = test_picks))
    page <- rvest::read_html(as.character(ui))
    labels <- rvest::html_text(rvest::html_elements(page, "label"))
    testthat::expect_true("sepal_pick" %in% labels)
    testthat::expect_true("species_pick" %in% labels)
  })

  it("includes the join_keys output element", {
    ui <- call_ui(tm_merge(picks = make_test_picks()))
    page <- rvest::read_html(as.character(ui))
    testthat::expect_length(rvest::html_elements(page, "#test-join_keys"), 1L)
  })

  it("includes the mapped output element", {
    ui <- call_ui(tm_merge(picks = make_test_picks()))
    page <- rvest::read_html(as.character(ui))
    testthat::expect_length(rvest::html_elements(page, "#test-mapped"), 1L)
  })

  it("includes the src output element", {
    ui <- call_ui(tm_merge(picks = make_test_picks()))
    page <- rvest::read_html(as.character(ui))
    testthat::expect_length(rvest::html_elements(page, "#test-src"), 1L)
  })

  it("includes the table_merged output element", {
    ui <- call_ui(tm_merge(picks = make_test_picks()))
    page <- rvest::read_html(as.character(ui))
    testthat::expect_length(
      rvest::html_elements(page, "#test-table_merged"), 1L
    )
  })
})
