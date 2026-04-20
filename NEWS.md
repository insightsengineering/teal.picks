# teal.picks 0.1.0.9225

### New Features

* Added `picks()`, `datasets()`, `variables()`, and `values()` functions for defining hierarchical data selections (dataset -> variable -> value).
* Added `picks_ui()` and `picks_srv()` Shiny modules for interactive selection widgets with badge drop-down UI.
* Added `resolver()` to resolve delayed and dynamic choices using `tidyselect` expressions and predicate functions.
* Added `merge_srv()` for merging multiple datasets based on picks selections, with automatic join key detection and conflict resolution.
* Added `tm_merge()` teal module for interactive dataset merging with generated R code.
* Added `as.picks()` for converting `teal.transform::data_extract_spec` objects to picks.
* Added `teal_transform_filter()` for creating filter transformers from picks selections.
* Added `is_categorical()` `tidyselect` helper for selecting categorical variables with cardinality constraints.

### Miscellaneous

* Initial public release.
