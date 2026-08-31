test_that(".onLoad registers teal.picks logger", {
  testthat::skip_if(getOption("testthat_interactive"))
  expect_no_error(.onLoad(libname = "dummy_lib", pkgname = "teal.picks"))
})
