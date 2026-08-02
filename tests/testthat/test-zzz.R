test_that(".onLoad registers teal.picks logger", {
  testthat::skip_if(getOption("testthat_interactive"))
  with_mocked_bindings(
    log_success = function(...) succeed(),
    .package = "logger",
    expect_success(.onLoad(libname = "", pkgname = "teal.picks"))
  )
})

test_that(".onload registers teal.picks handlers", {
  testthat::skip_if(getOption("testthat_interactive"))
  .onLoad(libname = "", pkgname = "teal.picks")
  registered_handlers_namespaces <- getFromNamespace("registered_handlers_namespaces", "teal.logger")
  expect_equal(registered_handlers_namespaces[["teal.picks"]], "teal.picks")
})
