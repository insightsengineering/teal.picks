.onLoad <- function(libname, pkgname) { # nolint
  # Set up the teal logger instance
  teal.logger::register_logger("teal.picks")
  teal.logger::register_handlers("teal.picks")

  # Manual import instead of using backports and adding 1 more dependency
  if (getRversion() < "4.4") {
    assign(
      "%||%",
      get("%||%", envir = getNamespace("rlang")),
      envir = getNamespace(pkgname)
    )
  }

  invisible()
}
