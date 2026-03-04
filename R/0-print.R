#' @export
print.pick <- function(x, ...) {
  cat(format(x, indent = 0))
  invisible(x)
}

#' @export
print.picks <- function(x, ...) {
  cat(format(x, indent = 0))
  invisible(x)
}

#' @export
format.picks <- function(x, indent = 0, ...) {
  out <- .indent(sprintf("%s\n", .bold("<picks>")), indent)
  for (i in seq_along(x)) {
    element_name <- names(x)[i]
    out <- paste0(out, .indent(sprintf("  %s:\n", .bold(sprintf("<%s>", element_name))), indent))
    out <- paste0(out, .format_pick_content(x[[i]], indent + 4))
    out <- paste0(out, .format_pick_attributes(x[[i]], indent + 4))
  }
  out
}

#' @export
format.pick <- function(x, indent = 0, ...) {
  element_class <- setdiff(class(x), "pick")[1]
  out <- .indent(sprintf("%s\n", .bold(sprintf("<%s>", element_class))), indent)
  out <- paste0(out, .format_pick_content(x, indent + 2))
  out <- paste0(out, .format_pick_attributes(x, indent + 2))
  out
}

.format_pick_content <- function(x, indent = 0) {
  out <- .indent(sprintf("%s %s\n", "choices:", .format_pick_value(x$choices)), indent)
  out <- paste0(out, .indent(sprintf("%s %s\n", "selected:", .format_pick_value(x$selected)), indent))
  out
}

.format_pick_attributes <- function(x, indent = 0) {
  attrs <- attributes(x)
  attrs_to_show <- attrs[!names(attrs) %in% c("class", "names")]
  if (length(attrs_to_show) > 0) {
    attrs_str <- vapply(names(attrs_to_show), function(name) {
      value <- attrs_to_show[[name]]
      sprintf("%s=%s", name, paste(value, collapse = ","))
    }, character(1))
    paste0(.indent(.italic(paste(attrs_str, collapse = ", ")), indent), "\n")
  } else {
    ""
  }
}

.format_pick_value <- function(x) {
  choices_str <- if (rlang::is_quosure(x) || is.function(x)) {
    rlang::as_label(x)
  } else if (length(x) == 0) {
    "~"
  } else {
    paste(x, collapse = ", ")
  }
}

.indent <- function(x, n) {
  paste(formatC("", width = n), x)
}

.bold <- function(x) {
  sprintf("\033[1m%s\033[0m", x)
}

.italic <- function(x) {
  sprintf("\033[3m%s\033[0m", x)
}
