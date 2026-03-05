.onLoad <- function(libname, pkgname) { # nolint
  # Set up the teal logger instance
  teal.logger::register_logger("teal.slice")
  teal.logger::register_handlers("teal.slice")
  invisible()
}
