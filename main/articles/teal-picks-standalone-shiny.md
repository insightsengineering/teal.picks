# teal.picks without teal (standalone Shiny)

## Introduction

You can use
[`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
and
[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
in a plain Shiny app: pass a reactive
[`teal.data::teal_data()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)
object to
[`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
and combine results with
[`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
when you need merged analysis data. This mirrors what
[`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md)
does inside `teal`, without
[`teal::init()`](https://insightsengineering.github.io/teal/latest-tag/reference/init.html).

Run the `shinyApp` chunk interactively.

[`library`](https://rdrr.io/r/base/library.html)`(`[`shiny`](https://shiny.posit.co/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`teal.data`](https://insightsengineering.github.io/teal.data/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`teal.picks`](https://github.com/insightsengineering/teal.picks/)`)`` `` ``data`` ``<-`` `[`teal_data`](https://insightsengineering.github.io/teal.data/latest-tag/reference/teal_data.html)`(``)`` ``data`` ``<-`` `[`within`](https://rdrr.io/r/base/with.html)`(``data``, ``{`` `` ``ADSL`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` USUBJID ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"S%03d"``, ``1``:``8``)``,`` `` AGE ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(``35``:``70``, ``8``, replace ``=`` ``TRUE``)``,`` `` stringsAsFactors ``=`` ``FALSE`` `` ``)`` `` ``ADLB`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` USUBJID ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"S%03d"``, ``1``:``8``)``, each ``=`` ``3``)``,`` `` PARAM ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"ALT"``, ``"AST"``, ``"BILI"``)``, ``8``)``,`` `` AVAL ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``24``, ``42``, ``6``)``, ``1``)``,`` `` stringsAsFactors ``=`` ``FALSE`` `` ``)`` ``}``)`` `` `[`join_keys`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)`(``data``)`` ``<-`` `[`join_keys`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)`(``teal.data``::`[`join_key`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_key.html)`(``"ADSL"``, ``"ADLB"``, keys ``=`` ``"USUBJID"``)``)`` `` ``selector_default`` ``<-`` `[`picks`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(`` `` `[`datasets`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(``choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ADSL"``, ``"ADLB"``)``, selected ``=`` ``"ADLB"``)``,`` `` `[`variables`](https://insightsengineering.github.io/teal.picks/reference/picks.md)`(`` `` choices ``=`` ``tidyselect``::`[`everything`](https://tidyselect.r-lib.org/reference/everything.html)`(``)``,`` `` selected ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1L``, ``2L``)``,`` `` multiple ``=`` ``TRUE`` `` ``)`` ``)`

## Minimal Shiny app

`ui`` ``<-`` `[`fluidPage`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` `[`titlePanel`](https://rdrr.io/pkg/shiny/man/titlePanel.html)`(``"Standalone picks + merge"``)``,`` `` `[`fluidRow`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(`` `` width ``=`` ``4``,`` `` `[`picks_ui`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)`(``"sel"``, picks ``=`` ``selector_default``)`` `` ``)``,`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(`` `` width ``=`` ``8``,`` `` ``tags``$``h4``(``"Mapped variables"``)``,`` `` `[`verbatimTextOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"mapped"``)``,`` `` ``tags``$``h4``(``"Merge preview"``)``,`` `` `[`tableOutput`](https://rdrr.io/pkg/shiny/man/renderTable.html)`(``"merged"``)`` `` ``)`` `` ``)`` ``)`` `` ``server`` ``<-`` ``function``(``input``, ``output``, ``session``)`` ``{`` `` ``data_r`` ``<-`` `[`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)`(``data``)`` `` `` ``selectors`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``sel ``=`` `[`picks_srv`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)`(``"sel"``, picks ``=`` ``selector_default``, data ``=`` ``data_r``)``)`` `` `` ``merged`` ``<-`` `[`merge_srv`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)`(`` `` id ``=`` ``"merge"``,`` `` data ``=`` ``data_r``,`` `` selectors ``=`` ``selectors``,`` `` output_name ``=`` ``"anl"``,`` `` join_fun ``=`` ``"dplyr::left_join"`` `` ``)`` `` `` ``output``$``mapped`` ``<-`` `[`renderPrint`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` ``yaml``::`[`as.yaml`](https://yaml.r-lib.org/reference/as.yaml.html)`(``merged``$``variables``(``)``)`` `` ``}``)`` `` `` ``output``$``merged`` ``<-`` `[`renderTable`](https://rdrr.io/pkg/shiny/man/renderTable.html)`(``{`` `` ``merged``$``data``(``)``[[``"anl"``]``]`` `` ``}``)`` ``}`` `` ``if`` ``(`[`interactive`](https://rdrr.io/r/base/interactive.html)`(``)``)`` ``{`` `` `[`shinyApp`](https://rdrr.io/pkg/shiny/man/shinyApp.html)`(``ui``, ``server``)`` ``}`

## Notes

- [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  expects `selectors` to be a named list of reactives (as returned by
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  for each selector).
- Define
  [`join_keys()`](https://insightsengineering.github.io/teal.data/latest-tag/reference/join_keys.html)
  on your `teal_data` before merging across datasets. One relationship
  between two datasets is enough:
  `join_keys(join_key("ADSL", "ADLB", keys = "USUBJID"))` is expanded by
  `teal.data` into a symmetric map so both names exist. Extra
  `join_key("DS", "DS", …)` self-keys are optional; they record
  primary-key / row grain (for example `USUBJID` + `PARAM` on long lab
  rows), which matters in full CDISC-style setups more than in this
  minimal example.
- For bookmarking,
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  stores resolved picks when `enableBookmarking = "server"` is used on
  [`shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).
- [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  filters the column(s) content chosen in
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md).
  If `multiple = TRUE` variables are selected, values are derived from a
  combined representation of those columns—so do not pair `PARAM`-only
  level choices with a selection that also includes `AVAL`. Use
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  with a single categorical column, or omit
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  when taking several columns (as in this example).
