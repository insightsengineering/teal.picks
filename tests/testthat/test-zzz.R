test_that(".onLoad registers teal.picks logger", {
  testthat::skip_if(getOption("testthat_interactive"))
  with_mocked_bindings(
    log_success = function(...) succeed(),
    .package = "logger",
    expect_success(.onLoad(libname = "dummy_lib", pkgname = "teal.picks"))
  )
})
