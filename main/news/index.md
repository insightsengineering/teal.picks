# Changelog

## teal.picks 0.1.0.9223

#### New Features

- Added
  [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md),
  and
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  functions for defining hierarchical data selections (dataset -\>
  variable -\> value).
- Added
  [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  and
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  Shiny modules for interactive selection widgets with badge drop-down
  UI.
- Added
  [`resolver()`](https://insightsengineering.github.io/teal.picks/reference/resolver.md)
  to resolve delayed and dynamic choices using `tidyselect` expressions
  and predicate functions.
- Added
  [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  for merging multiple datasets based on picks selections, with
  automatic join key detection and conflict resolution.
- Added
  [`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md)
  teal module for interactive dataset merging with generated R code.
- Added
  [`as.picks()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  for converting
  [`teal.transform::data_extract_spec`](https://insightsengineering.github.io/teal.transform/latest-tag/reference/data_extract_spec.html)
  objects to picks.
- Added
  [`teal_transform_filter()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  for creating filter transformers from picks selections.
- Added
  [`is_categorical()`](https://insightsengineering.github.io/teal.picks/reference/tidyselectors.md)
  `tidyselect` helper for selecting categorical variables with
  cardinality constraints.

#### Miscellaneous

- Initial public release.
