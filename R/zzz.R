.onLoad <- function(libname, pkgname) { # nolint
  # Set up the teal logger instance
  teal.logger::register_logger("teal.slice")
  teal.logger::register_handlers("teal.slice")

  # Manual import instead of using backports and adding 1 more dependency
  if (getRversion() < "4.4") {
    assign("%||%", rlang::`%||%`, envir = getNamespace(pkgname))
  }

  invisible()
}
