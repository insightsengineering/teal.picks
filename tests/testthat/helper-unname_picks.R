unname_picks <- function(x) {
  x[] <- lapply(x, unname.pick)
  x
}

unname.pick <- function(obj) {
  obj$selected <- unname(obj$selected)
  obj$choices <- unname(obj$choices)
  obj
}
