# Escape a string for use as a JavaScript double-quoted literal (ids, Shiny input names, values).
.teal_picks_js_id_literal <- function(id) { # nolint: object_length_linter, line_length_linter.
  id <- gsub("\\", "\\\\", id, fixed = TRUE)
  id <- gsub("\"", "\\\"", id, fixed = TRUE)
  id <- gsub("\r", "\\r", id, fixed = TRUE)
  id <- gsub("\n", "\\n", id, fixed = TRUE)
  paste0("\"", id, "\"")
}

# JSON `[]`, a JSON string, or JSON string array for embedded JS (see `singleton_as_bare_string`).
#
# When `singleton_as_bare_string` is `TRUE` and `length(val) == 1L`, return a single JSON string
# token (e.g. `"foo"`). Otherwise return a JSON array (`[]`, `["a"]`, or `["a","b"]`). The
# always-array form is used where `const arr = ...` must remain an array (DOM sync script).
.teal_picks_js_json_collection_literal <- function(val, singleton_as_bare_string = FALSE) { # nolint: object_length_linter, line_length_linter.
  val <- as.character(val)
  if (length(val) == 0L) {
    return("[]")
  }
  parts <- vapply(val, .teal_picks_js_id_literal, character(1))
  if (isTRUE(singleton_as_bare_string) && length(val) == 1L) {
    return(parts[[1L]])
  }
  paste0("[", paste(parts, collapse = ","), "]")
}

# Scalar string or character vector for `AppDriver$set_inputs()` (empty multi-select: `character(0)`).
.teal_picks_shiny_selected_value_for_set_inputs <- function(val) { # nolint: object_length_linter.
  val <- as.character(val)
  if (length(val) == 0L) {
    character(0)
  } else if (length(val) == 1L) {
    val[[1L]]
  } else {
    val
  }
}

# Sync native <select> + bootstrap-select widget, then let Shiny read change events.
.teal_picks_apply_select_value_in_browser <- function(app_driver, select_id, val) { # nolint: object_length_linter.
  checkmate::assert_string(select_id)
  val <- as.character(val)
  id_lit <- .teal_picks_js_id_literal(select_id)
  arr_lit <- .teal_picks_js_json_collection_literal(val)
  app_driver$run_js(sprintf(
    paste0(
      "(() => {\n",
      "  const sel = document.getElementById(%s);\n",
      "  if (!sel) return false;\n",
      "  const arr = %s;\n",
      "  if (sel.multiple) {\n",
      "    const wanted = new Set(arr);\n",
      "    for (const o of sel.options) o.selected = wanted.has(o.value);\n",
      "  } else {\n",
      "    sel.value = arr.length ? arr[0] : '';\n",
      "  }\n",
      "  if (window.jQuery && jQuery(sel).data('selectpicker')) {\n",
      "    if (sel.multiple) {\n",
      "      jQuery(sel).selectpicker('val', arr);\n",
      "    } else {\n",
      "      jQuery(sel).selectpicker('val', arr.length ? arr[0] : '');\n",
      "    }\n",
      "    jQuery(sel).selectpicker('refresh');\n",
      "  }\n",
      "  sel.dispatchEvent(new Event('input', { bubbles: true }));\n",
      "  sel.dispatchEvent(new Event('change', { bubbles: true }));\n",
      "  return true;\n",
      "})()"
    ),
    id_lit,
    arr_lit
  ))
  invisible(app_driver)
}

# Push values through Shiny and force teal.picks picker commit (`*_open` TRUE then FALSE).
# Uses [`AppDriver$set_inputs()`] with `priority_ = "event"` and `allow_no_input_binding_ = TRUE`
# so shinytest2 waits for the last flush (unbound picker inputs).
.teal_picks_shiny_set_picker_and_commit <- function(app_driver, sel_id, open_id, val) { # nolint: object_length_linter.
  checkmate::assert_string(sel_id)
  checkmate::assert_string(open_id)
  val <- as.character(val)
  sel_value <- .teal_picks_shiny_selected_value_for_set_inputs(val)

  do_call_set_inputs <- function(named_inputs, wait_) {
    do.call(
      app_driver$set_inputs,
      c(
        named_inputs,
        list(
          priority_ = "event",
          allow_no_input_binding_ = TRUE,
          wait_ = wait_
        )
      )
    )
  }

  do_call_set_inputs(stats::setNames(list(sel_value), sel_id), wait_ = FALSE)
  do_call_set_inputs(stats::setNames(list(TRUE), open_id), wait_ = FALSE)
  do_call_set_inputs(stats::setNames(list(FALSE), open_id), wait_ = TRUE)
  invisible(app_driver)
}

# Click the teal.picks summary badge (toggles the dropdown open/closed).
# Use document.querySelector via run_js (Runtime.evaluate) instead of AppDriver$click(CSS) or
# getElementById: Chromote CDP DOM commands can return error -32000 for some selectors in CI.
# The badge ID ends with "-<pick_id>-inputs-summary_badge" regardless of the teal module namespace.
.teal_picks_click_summary_badge <- function(app_driver, pick_id) { # nolint: object_length_linter.
  checkmate::assert_string(pick_id)
  sel_lit <- .teal_picks_js_id_literal(sprintf('[id$="-%s-inputs-summary_badge"]', pick_id))
  app_driver$wait_for_js(sprintf("document.querySelector(%s) !== null", sel_lit))
  app_driver$run_js(sprintf(
    "(function() { var el = document.querySelector(%s); if (el) el.click(); })()",
    sel_lit
  ))
  app_driver$wait_for_idle()
  invisible(app_driver)
}

#' Read the selected values from a categorical teal.picks slot.
#'
#' While the summary badge has never been opened, picker inputs are not bound.
#' This helper reads the committed values from exported picks state.
#'
#' @param app_driver App driver object.
#' @param pick_id `character(1)` teal.picks id.
#' @param slot `character(1)` slot name. Defaults to `"variables"`.
#'
#' @return Selected value(s) for the requested slot.
#' @keywords internal
app_driver_get_teal_picks_slot <- function(app_driver, pick_id, slot = "variables") {
  checkmate::assert_class(app_driver, "AppDriver")
  checkmate::assert_string(pick_id)
  checkmate::assert_string(slot)
  selected_pick <- app_driver_teal_picks_exports(app_driver, pick_id)[["picks_resolved"]]
  selected_pick[[slot]]$selected
}

#' Read all teal.picks exported values for a module namespace.
#'
#' The module namespace is inferred from the summary badge id in the DOM,
#' then used to filter exported values.
#'
#' @param app_driver App driver object.
#' @param pick_id `character(1)` teal.picks id.
#'
#' @return Named list of module-scoped exported values.
#' @keywords internal
app_driver_teal_picks_exports <- function(app_driver, pick_id) {
  checkmate::assert_class(app_driver, "AppDriver")
  checkmate::assert_string(pick_id)
  sel_lit <- .teal_picks_js_id_literal(sprintf('[id$="-%s-inputs-summary_badge"]', pick_id))
  badge_id <- app_driver$get_js(sprintf(
    "(function() { var el = document.querySelector(%s); return el ? el.id : null; })()",
    sel_lit
  ))
  module_ns <- sub("-inputs-summary_badge$", "", badge_id)
  exports <- app_driver$get_values(export = TRUE)$export
  exports_filtered <- exports[grepl(sprintf("^%s-", module_ns), names(exports))]
  names(exports_filtered) <- sub(sprintf("^%s-", module_ns), "", names(exports_filtered))
  exports_filtered
}

#' Set a categorical teal.picks slot value.
#'
#' This helper synchronizes native and bootstrap-select state and commits via
#' the teal.picks open/close input pulse.
#'
#' @param app_driver App driver object.
#' @param pick_id `character(1)` teal.picks id.
#' @param slot `character(1)` slot name.
#' @param value `NULL` or character vector of selected values.
#' @param wait `logical(1)` if `TRUE`, wait for idle after commit.
#'
#' @return Invisibly returns `app_driver`.
#' @keywords internal
app_driver_set_teal_picks_slot <- function(app_driver, pick_id, slot, value, wait = TRUE) {
  checkmate::assert_class(app_driver, "AppDriver")
  checkmate::assert_string(pick_id)
  checkmate::assert_string(slot)
  checkmate::assert_flag(wait)
  .teal_picks_click_summary_badge(app_driver, pick_id)
  exports <- app_driver_teal_picks_exports(app_driver, pick_id)
  sel_id <- sprintf(exports$selected_id_fmt, slot)
  open_id <- sprintf(exports$open_id_fmt, slot)
  val <- if (is.null(value)) character(0L) else as.character(value)
  .teal_picks_apply_select_value_in_browser(app_driver, sel_id, val)
  .teal_picks_shiny_set_picker_and_commit(app_driver, sel_id, open_id, val)
  if (isTRUE(wait)) {
    app_driver$wait_for_idle()
  }
  .teal_picks_click_summary_badge(app_driver, pick_id)
  invisible(app_driver)
}

#' Expect that a CSS selector resolves to at least one visible element.
#'
#' @param selector `character(1)` CSS selector to check.
#' @param app_driver App driver object.
#' @param timeout `numeric(1)` maximum wait time.
#'
#' @return Called expectation result.
#' @keywords internal
app_driver_expect_visible <- function(selector, app_driver, timeout) {
  checkmate::assert_class(app_driver, "AppDriver")
  checkmate::assert_string(selector)
  selector <- .teal_picks_js_id_literal(selector)

  tryCatch(
    {
      app_driver$wait_for_js(
        sprintf(
          paste0(
            "Array.from(document.querySelectorAll(%s))",
            ".map(function(el) {",
            "  var cs = window.getComputedStyle(el);",
            "  return cs.display !== 'none' && cs.visibility !== 'hidden' &&",
            "    el.style.opacity !== '0' &&",
            "    (el.textContent.trim().length > 0 || el.children.length > 0);",
            "})",
            ".some(Boolean)"
          ),
          selector
        ),
        timeout
      )
      testthat::succeed()
    },
    error = function(err) {
      testthat::fail(sprintf("CSS selector '%s' does not produce any visible elements.", selector))
    }
  )
}

#' @describeIn app_driver_expect_visible Check if a selector is hidden for a given timeout.
app_driver_expect_hidden <- function(selector, app_driver, timeout) {
  checkmate::assert_class(app_driver, "AppDriver")
  checkmate::assert_string(selector)
  selector <- .teal_picks_js_id_literal(selector)
  tryCatch(
    {
      app_driver$wait_for_js(
        sprintf(
          paste0(
            "!Array.from(document.querySelectorAll(%s))",
            ".map(function(el) {",
            "  var cs = window.getComputedStyle(el);",
            "  return cs.display !== 'none' && cs.visibility !== 'hidden' &&",
            "    el.style.opacity !== '0' &&",
            "    (el.textContent.trim().length > 0 || el.children.length > 0);",
            "})",
            ".some(Boolean)"
          ),
          selector
        ),
        timeout
      )
      testthat::succeed()
    },
    error = function(err) {
      testthat::fail(sprintf("CSS selector '%s' produces visible elements.", selector))
    }
  )
}
