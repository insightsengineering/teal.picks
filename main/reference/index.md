# Package index

## Picks

Define hierarchical data selections

- [`picks()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  [`datasets()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  [`variables()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  [`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
  : Choices/selected settings

## Choices/selected helpers

Utility functions

- [`is_categorical()`](https://insightsengineering.github.io/teal.picks/reference/tidyselectors.md)
  **\[experimental\]** :

  `tidyselect` helpers

- [`interaction_vars()`](https://insightsengineering.github.io/teal.picks/reference/interaction_vars.md)
  :

  Declare interaction variable pairs for `tidyselect`

- [`ranged()`](https://insightsengineering.github.io/teal.picks/reference/ranged.md)
  : Select a range

## Shiny Modules

Interactive UI components for picks

- [`picks_ui()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  [`picks_srv()`](https://insightsengineering.github.io/teal.picks/reference/picks_module.md)
  : Interactive picks

## Resolution

Resolve delayed and dynamic choices

- [`resolver()`](https://insightsengineering.github.io/teal.picks/reference/resolver.md)
  :

  Resolve `picks`

- [`determine()`](https://insightsengineering.github.io/teal.picks/reference/determine.md)
  : A method that should take a type and resolve it.

## Merge

Merge datasets based on picks selections

- [`merge_srv()`](https://insightsengineering.github.io/teal.picks/reference/merge_srv.md)
  : Merge Server Function for Dataset Integration
- [`tm_merge()`](https://insightsengineering.github.io/teal.picks/reference/tm_merge.md)
  : Merge module

## Conversion

Convert from teal.transform objects

- [`as.picks()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  [`teal_transform_filter()`](https://insightsengineering.github.io/teal.picks/reference/as.picks.md)
  **\[experimental\]** : Convert data_extract_spec to picks

## Developer utilities

Help with picks

- [`check_last_level()`](https://insightsengineering.github.io/teal.picks/reference/assert_last_level.md)
  [`assert_last_level()`](https://insightsengineering.github.io/teal.picks/reference/assert_last_level.md)
  : Assert level
- [`is_pick_multiple()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md)
  [`is_pick_fixed()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md)
  [`is_pick_ordered()`](https://insightsengineering.github.io/teal.picks/reference/helper_functions_pick.md)
  : Helper functions to check pick attributes

## Testing utility functions

Help testing teal modules with teal.picks objects

- [`app_driver_set_teal_picks_slot()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_set_teal_picks_slot.md)
  : Set a categorical teal.picks slot value.
- [`app_driver_get_teal_picks_slot()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_get_teal_picks_slot.md)
  : Read the selected values from a categorical teal.picks slot.
- [`app_driver_expect_picks_visible()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_expect_picks_visible.md)
  [`app_driver_expect_picks_hidden()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_expect_picks_visible.md)
  : Expect that a CSS selector resolves to at least one visible element.
- [`app_driver_teal_picks_exports()`](https://insightsengineering.github.io/teal.picks/reference/app_driver_teal_picks_exports.md)
  : Read all teal.picks exported values for a module namespace.
