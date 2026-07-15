# teal.picks 0.2.0.9001

### Enhancements

* Fixed `variables` selection popup to show "Select all"/"Deselect all" when multiple selection is enabled.
* Adds assertion to check for specific elements of picks to API.

# teal.picks 0.2.0

### Bug fixes

* Fixed a bug that crashes the `picks_srv` when datasets with labels that contain lists. Defaults to the choice name (#96).

### Miscellaneous

* `variables()` allows for custom `allow-clear` options to be set by user without being overwritten.
* Improve badge border and looks.
* Update maintainer.

# teal.picks 0.1.0

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
