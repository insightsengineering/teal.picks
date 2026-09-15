.onLoad <- function(libname, pkgname) { # nolint
  # Set up the teal logger instance
  teal.logger::register_logger(pkgname)
  teal.logger::register_handlers(pkgname)
  invisible()
}
