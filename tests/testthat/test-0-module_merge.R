testthat::describe("merge_srv accepts selectors argument", {
  it("accepts named list of shiny::reactive picks", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
      adae <- data.frame(studyid = "A", usubjid = c("1", "2"), AVAL = c(1.5, 2.5))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid")),
      teal.data::join_key("adae", "adae", c("studyid", "usubjid", "paramcd", "avisit")),
      teal.data::join_key("adsl", "adae", c("studyid", "usubjid"))
    )

    selectors <- list(
      a = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age"))),
      b = shiny::reactive(picks(datasets("adae", "adae"), variables("AVAL", "AVAL")))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_no_error(
        merge_srv(
          id = "test",
          data = shiny::reactive(data),
          selectors = selectors
        )
      )
    )
  })

  it("doesn't accept non-reactive list elements", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(
      a = picks(
        datasets(choices = "adsl", selected = "adsl"),
        variables(choices = "age", selected = "age")
      )
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_error(
        merge_srv(
          id = "test",
          data = shiny::reactive(data),
          selectors = selectors
        ),
        "reactive"
      )
    )
  })

  it("doesn't accept unnamed list of selectors", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(
      shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age")))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_error(
        merge_srv(
          id = "test",
          data = shiny::reactive(data),
          selectors = selectors
        )
      )
    )
  })

  it("accepts empty list of selectors", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list()

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_no_error(
        merge_srv(
          id = "test",
          data = shiny::reactive(data),
          selectors = selectors
        )
      )
    )
  })
})

testthat::describe("merge_srv accepts data argument", {
  it("accepts shiny::reactive teal_data", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(
      a = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age")))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_no_error(
        merge_srv(
          id = "test",
          data = shiny::reactive(data),
          selectors = selectors
        )
      )
    )
  })

  it("doesn't accept non-reactive teal_data", {
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(
      adsl = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age")))
    )

    shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = testthat::expect_error(
        merge_srv(
          id = "test",
          data = data,
          selectors = selectors
        )
      )
    )
  })
})

testthat::describe("merge_srv returns list with data (teal_data with anl) and variables (selected anl variables)", {
  it("returns list with two reactives: variables and data", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(a = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age"))))
    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )
    testthat::expect_named(out, c("data", "variables"))
    checkmate::expect_class(out$variables, "reactive")
    checkmate::expect_class(out$data, "reactive")
  })

  it("$data returns reactive containing teal_data with object `output_name`", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(a = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age"))))
    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "abcd")
    )
    checkmate::expect_class(out$data(), "teal_data")
    testthat::expect_named(out$data(), c("abcd", "adsl"))
  })

  it("$data() returns teal_data with merged anl using join_fun", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = c("id")),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(datasets("customers", "customers"), variables("name", "name"))),
      b = shiny::reactive(picks(datasets("orders", "orders"), variables("date", "date")))
    )
    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, join_fun = "dplyr::left_join")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id, name) %>%
          dplyr::left_join(y = dplyr::select(orders, customer_id, date), by = c(id = "customer_id"))
      })
    )
  })

  it("$variables returns reactive list named after selectors", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      adsl <- data.frame(studyid = "A", usubjid = c("1", "2"), age = c(30, 40))
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("adsl", "adsl", c("studyid", "usubjid"))
    )

    selectors <- list(
      a = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age"))),
      b = shiny::reactive(picks(datasets("adsl", "adsl"), variables("age", "age")))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "abcd")
    )
    checkmate::expect_list(out$variables())
    testthat::expect_named(out$variables(), c("a", "b"))
  })

  it("anl contains selected colnames with original names if variables are selected from a single dataset", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      iris <- iris
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "iris", selected = "iris"),
        variables(choices = colnames(iris), selected = "Species")
      )),
      b = shiny::reactive(picks(
        datasets(choices = "iris", selected = "iris"),
        variables(choices = colnames(iris), selected = c("Sepal.Length", "Sepal.Width"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, anl <- dplyr::select(iris, Species, Sepal.Length, Sepal.Width))
    )
    testthat::expect_identical(out$variables(), list(a = "Species", b = c("Sepal.Length", "Sepal.Width")))
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("anl contains selected colnames with original names if selected from a multiple datasets and not duplicated", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = c("id")),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "age"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("date", "total_amount"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id, name, age) %>%
          dplyr::inner_join(
            y = dplyr::select(orders, customer_id, date, total_amount),
            by = c(id = "customer_id"),
            suffix = c("", "_orders")
          )
      })
    )
    testthat::expect_identical(out$variables(), list(a = c("name", "age"), b = c("date", "total_amount")))
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("anl contains selected colnames with suffixes names if duplicated across datasets", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = c("id")),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "status"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("date", "status"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )
    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id, name, status) %>%
          dplyr::inner_join(
            y = dplyr::select(orders, customer_id, date, status),
            by = c(id = "customer_id"),
            suffix = c("", "_orders")
          )
      })
    )
    testthat::expect_identical(out$variables(), list(a = c("name", "status"), b = c("date", "status_orders")))
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("anl contains colnames with original names when duplicated for the same dataset", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("id", "status"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("id", "status"))
      )),
      c = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "id"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id, status, name)
      })
    )
    testthat::expect_identical(
      out$variables(),
      list(a = c("id", "status"), b = c("id", "status"), c = c("name", "id"))
    )
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("anl can merge deep join tree by pair keys and finds correct merge order", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )

      order_items <- tibble::tribble(
        ~id, ~order_id, ~product, ~quantity, ~price,
        1001, 101, "Widget A", 2, 25,
        1002, 101, "Widget B", 1, 50,
        1003, 102, "Widget C", 3, 66.67,
        1004, 103, "Widget A", 5, 60
      )

      shipments <- tibble::tribble(
        ~id, ~item_id, ~tracking_number, ~carrier, ~shipped_date,
        5001, 1001, "TRK123456", "FedEx", as.Date("2024-01-16"),
        5002, 1002, "TRK123457", "UPS", as.Date("2024-01-16"),
        5003, 1003, "TRK123458", "FedEx", as.Date("2024-02-02"),
        5004, 1004, "TRK123459", "DHL", as.Date("2024-02-11")
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = "id"),
      teal.data::join_key("order_items", keys = "id"),
      teal.data::join_key("shipments", keys = "id"),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id")),
      teal.data::join_key("orders", "order_items", keys = c(id = "order_id")),
      teal.data::join_key("order_items", "shipments", keys = c(id = "item_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "shipments", selected = "shipments"),
        variables(choices = colnames(data$shipments), selected = c("tracking_number", "carrier"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "age"))
      )),
      c = shiny::reactive(picks(
        datasets(choices = "order_items", selected = "order_items"),
        variables(choices = colnames(data$order_items), selected = c("product", "quantity"))
      )),
      d = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("date", "total_amount"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id, name, age) %>%
          dplyr::inner_join(
            y = dplyr::select(orders, customer_id, id, date, total_amount),
            by = c(id = "customer_id"),
            suffix = c("", "_orders")
          ) %>%
          dplyr::inner_join(
            y = dplyr::select(order_items, order_id, id, product, quantity),
            by = c(id_orders = "order_id"),
            suffix = c("", "_order_items")
          ) %>%
          dplyr::inner_join(
            y = dplyr::select(shipments, item_id, tracking_number, carrier),
            by = c(id_order_items = "item_id"),
            suffix = c("", "_shipments")
          )
      })
    )
    testthat::expect_identical(
      out$variables(),
      list(
        b = c("name", "age"),
        d = c("date", "total_amount"),
        c = c("product", "quantity"),
        a = c("tracking_number", "carrier")
      )
    )
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("selected join_keys across multiple datasets refers to the same column in anl c( O.O )ɔ", {
    # ie. when `*_join(a, b, by = c(id = "id_parent"))` the second column won't be included as it is
    #  referring to the same column
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )

      order_items <- tibble::tribble(
        ~id, ~order_id, ~product, ~quantity, ~price,
        1001, 101, "Widget A", 2, 25,
        1002, 101, "Widget B", 1, 50,
        1003, 102, "Widget C", 3, 66.67,
        1004, 103, "Widget A", 5, 60
      )

      shipments <- tibble::tribble(
        ~id, ~item_id, ~tracking_number, ~carrier, ~shipped_date,
        5001, 1001, "TRK123456", "FedEx", as.Date("2024-01-16"),
        5002, 1002, "TRK123457", "UPS", as.Date("2024-01-16"),
        5003, 1003, "TRK123458", "FedEx", as.Date("2024-02-02"),
        5004, 1004, "TRK123459", "DHL", as.Date("2024-02-11")
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = "id"),
      teal.data::join_key("order_items", keys = "id"),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id")),
      teal.data::join_key("orders", "order_items", keys = c(id = "order_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = "id")
      )),
      b = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("id", "customer_id"))
      )),
      c = shiny::reactive(picks(
        datasets(choices = "order_items", selected = "order_items"),
        variables(choices = colnames(data$order_items), selected = "order_id", )
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(customers, id) %>%
          dplyr::inner_join(
            y = dplyr::select(orders, customer_id, id),
            by = c(id = "customer_id"),
            suffix = c("", "_orders")
          ) %>%
          dplyr::inner_join(
            y = dplyr::select(order_items, order_id),
            by = c(id_orders = "order_id"),
            suffix = c("", "_order_items")
          )
      })
    )
    testthat::expect_identical(
      out$variables(),
      list(a = "id", b = c("id_orders", "id"), c = "id_orders") #
    )
    testthat::expect_in(unique(unlist(out$variables())), colnames(out$data()$anl))
  })

  it("join_keys are updated to contains anl <-> anl-components", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )

      order_items <- tibble::tribble(
        ~id, ~order_id, ~product, ~quantity, ~price,
        1001, 101, "Widget A", 2, 25,
        1002, 101, "Widget B", 1, 50,
        1003, 102, "Widget C", 3, 66.67,
        1004, 103, "Widget A", 5, 60
      )

      shipments <- tibble::tribble(
        ~id, ~item_id, ~tracking_number, ~carrier, ~shipped_date,
        5001, 1001, "TRK123456", "FedEx", as.Date("2024-01-16"),
        5002, 1002, "TRK123457", "UPS", as.Date("2024-01-16"),
        5003, 1003, "TRK123458", "FedEx", as.Date("2024-02-02"),
        5004, 1004, "TRK123459", "DHL", as.Date("2024-02-11")
      )
    })
    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = "id"),
      teal.data::join_key("order_items", keys = "id"),
      teal.data::join_key("shipments", keys = "id"),
      teal.data::join_key("customers", "orders", keys = c(id = "customer_id")),
      teal.data::join_key("orders", "order_items", keys = c(id = "order_id")),
      teal.data::join_key("order_items", "shipments", keys = c(id = "item_id"))
    )

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "shipments", selected = "shipments"),
        variables(choices = colnames(data$shipments), selected = c("tracking_number", "carrier"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "age"))
      )),
      c = shiny::reactive(picks(
        datasets(choices = "order_items", selected = "order_items"),
        variables(choices = colnames(data$order_items), selected = c("product", "quantity"))
      )),
      d = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("date", "total_amount"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )

    testthat::expect_identical(
      teal.data::join_keys(out$data())$anl,
      list(
        shipments = c(id_order_items = "item_id"),
        order_items = c(id_orders = "order_id"),
        orders = c(id = "customer_id")
      )
    )
  })

  it("anl is filtered by factor variable when values is selected", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        factor_var = factor(c("A", "B", "C", "A", "B"), levels = c("A", "B", "C")),
        id = 1:5
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "test_data", selected = "test_data"),
        variables(choices = colnames(data$test_data), selected = "factor_var"),
        values(choices = c("A", "B", "C"), selected = c("A", "B"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(test_data, factor_var) %>%
          dplyr::filter(factor_var %in% c("A", "B"))
      })
    )
  })

  it("anl is filtered by numeric variable when values is selected", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        numeric_var = c(1.5, 2.5, 3.5, 4.5, 5.5),
        id = 1:5
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "test_data", selected = "test_data"),
        variables(choices = colnames(data$test_data), selected = "numeric_var"),
        values(choices = range(data$test_data$numeric_var), selected = c(2.0, 4.0))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(test_data, numeric_var) %>%
          dplyr::filter(numeric_var >= 2.0 & numeric_var <= 4.0)
      })
    )
  })

  it("anl is filtered by date variable when values is selected", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        date_var = as.Date(c("2024-01-01", "2024-02-01", "2024-03-01", "2024-04-01", "2024-05-01")),
        id = 1:5
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "test_data", selected = "test_data"),
        variables(choices = colnames(data$test_data), selected = "date_var"),
        values(choices = range(data$test_data$date_var), selected = as.Date(c("2024-01-15", "2024-03-15")))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(test_data, date_var) %>%
          dplyr::filter(date_var >= as.Date("2024-01-15") & date_var <= as.Date("2024-03-15"))
      })
    )
  })

  it("anl is filtered by POSIXct variable when values is selected", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        posixct_var = as.POSIXct(c(
          "2024-01-01 10:00:00", "2024-02-01 11:00:00", "2024-03-01 12:00:00",
          "2024-04-01 13:00:00", "2024-05-01 14:00:00"
        )),
        id = 1:5
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "test_data", selected = "test_data"),
        variables(choices = colnames(data$test_data), selected = "posixct_var"),
        values(
          choices = range(data$test_data$posixct_var),
          selected = as.POSIXct(c("2024-01-15 00:00:00", "2024-04-15 00:00:00"))
        )
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(test_data, posixct_var) %>%
          dplyr::filter(
            posixct_var >= as.POSIXct("2024-01-15 00:00:00") &
              posixct_var <= as.POSIXct("2024-04-15 00:00:00")
          )
      })
    )
  })

  it("anl is filtered by logical variable when values is selected", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      test_data <- data.frame(
        logical_var = c(TRUE, FALSE, TRUE, FALSE, TRUE),
        id = 1:5
      )
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "test_data", selected = "test_data"),
        variables(choices = colnames(data$test_data), selected = "logical_var"),
        values(choices = c(TRUE, FALSE), selected = TRUE)
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors, output_name = "anl")
    )

    testthat::expect_equal(
      out$data(),
      within(data, {
        anl <- dplyr::select(test_data, logical_var) %>%
          dplyr::filter(logical_var)
      })
    )
  })

  it("fails when selected from multiple datasets and no join-keys/primary-keys", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      iris <- iris
      mtcars <- mtcars
    })

    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "mtcars", selected = "mtcars"),
        variables(choices = colnames(mtcars), selected = "mpg")
      )),
      b = shiny::reactive(picks(
        datasets(choices = "iris", selected = "iris"),
        variables(choices = colnames(iris), selected = c("Sepal.Length", "Sepal.Width"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )
    testthat::expect_error(out$variables(), regexp = "no join keys defined", class = "validation")
    testthat::expect_error(out$data(), regexp = "no join keys defined", class = "validation")
  })

  it("fails when selected from multiple datasets and no join-keys between selected datasets", {
    shiny::reactiveConsole(TRUE)
    on.exit(reactiveConsole(FALSE))
    data <- within(teal.data::teal_data(), {
      customers <- tibble::tribble(
        ~id, ~name, ~age, ~status,
        1, "Alice Johnson", 30, "active",
        2, "Bob Smith", 25, "active",
        3, "Charlie Brown", 35, "inactive"
      )

      orders <- tibble::tribble(
        ~id, ~customer_id, ~date, ~status, ~total_amount,
        101, 1, as.Date("2024-01-15"), "shipped", 100,
        102, 2, as.Date("2024-02-01"), "pending", 200,
        103, 3, as.Date("2024-02-10"), "delivered", 300
      )
    })

    teal.data::join_keys(data) <- teal.data::join_keys(
      teal.data::join_key("customers", keys = "id"),
      teal.data::join_key("orders", keys = c("id"))
    )


    selectors <- list(
      a = shiny::reactive(picks(
        datasets(choices = "customers", selected = "customers"),
        variables(choices = colnames(data$customers), selected = c("name", "status"))
      )),
      b = shiny::reactive(picks(
        datasets(choices = "orders", selected = "orders"),
        variables(choices = colnames(data$orders), selected = c("date", "status"))
      ))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )
    testthat::expect_error(out$variables(), regexp = "No join keys found between", class = "validation")
    testthat::expect_error(out$data(), regexp = "No join keys found between", class = "validation")
  })

  it("fails when unresolved picks are passed to the module", {
    shiny::reactiveConsole(TRUE)
    on.exit(shiny::reactiveConsole(FALSE))
    data <- teal.data::teal_data()
    data <- within(data, {
      iris <- iris
    })

    selectors <- list(
      a = shiny::reactive(picks(datasets(choices = "iris", selected = "iris"), variables(selected = 1L))),
      b = shiny::reactive(picks(datasets(choices = "iris", selected = "iris"), variables(selected = 1L)))
    )

    out <- shiny::withReactiveDomain(
      domain = shiny::MockShinySession$new(),
      expr = merge_srv(id = "test", data = shiny::reactive(data), selectors = selectors)
    )
    testthat::expect_error(out$variables(), regexp = "have not been resolved correctly", class = "validation")
    testthat::expect_error(out$data(), regexp = "have not been resolved correctly", class = "validation")
  })
})
