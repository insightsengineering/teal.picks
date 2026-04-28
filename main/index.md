# teal.picks

[![CRAN
Version](https://www.r-pkg.org/badges/version/teal.picks?color=green)](https://cran.r-project.org/package=teal.picks)
[![Total
Downloads](http://cranlogs.r-pkg.org/badges/grand-total/teal.picks?color=green)](https://cran.r-project.org/package=teal.picks)
[![Last Month
Downloads](http://cranlogs.r-pkg.org/badges/last-month/teal.picks?color=green)](https://cran.r-project.org/package=teal.picks)
[![Last Week
Downloads](http://cranlogs.r-pkg.org/badges/last-week/teal.picks?color=green)](https://cran.r-project.org/package=teal.picks)

[![Check
🛠](https://github.com/insightsengineering/teal.picks/actions/workflows/check.yaml/badge.svg)](https://insightsengineering.github.io/teal.picks/main/unit-test-report/)
[![Docs
📚](https://github.com/insightsengineering/teal.picks/actions/workflows/docs.yaml/badge.svg)](https://insightsengineering.github.io/teal.picks/)
[![Code Coverage
📔](https://raw.githubusercontent.com/insightsengineering/teal.picks/_xml_coverage_reports/data/main/badge.svg)](https://insightsengineering.github.io/teal.picks/main/coverage-report/)

![GitHub
forks](https://img.shields.io/github/forks/insightsengineering/teal.picks?style=social)![GitHub
repo
stars](https://img.shields.io/github/stars/insightsengineering/teal.picks?style=social)

![GitHub commit
activity](https://img.shields.io/github/commit-activity/m/insightsengineering/teal.picks)![GitHub
contributors](https://img.shields.io/github/contributors/insightsengineering/teal.picks)![GitHub
last
commit](https://img.shields.io/github/last-commit/insightsengineering/teal.picks)![GitHub
pull
requests](https://img.shields.io/github/issues-pr/insightsengineering/teal.picks)![GitHub
repo
size](https://img.shields.io/github/repo-size/insightsengineering/teal.picks)![GitHub
language
count](https://img.shields.io/github/languages/count/insightsengineering/teal.picks)[![Project
Status: Active – The project has reached a stable, usable state and is
being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Current
Version](https://img.shields.io/github/r-package/v/insightsengineering/teal.picks/main?color=purple&label=package%20version)](https://github.com/insightsengineering/teal.picks/tree/main)
[![Open
Issues](https://img.shields.io/github/issues-raw/insightsengineering/teal.picks?color=red&label=open%20issues)](https://github.com/insightsengineering/teal.picks/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc)

`teal.picks` is an `R` package used in the development of
[`teal`](https://insightsengineering.github.io/teal/) applications. It
provides:

- a hierarchical **choices / selected** model for datasets, variables,
  and values in a Shiny session, with optional **tidyselect** support
  for dynamic choices,
- **`picks_ui`** and **`picks_srv`** modules to collect those selections
  interactively,
- **`merge_srv`** and **`tm_merge`** to merge `teal` data according to
  user picks,
- conversion helpers such as **`as.picks`** to align with
  **`teal.transform`** objects.

## Installation

``` r

install.packages('teal.picks')
```

Alternatively, you might want to use the development version.

``` r

# install.packages("pak")
pak::pak("insightsengineering/teal.picks")
```

## Usage

See the [package
reference](https://insightsengineering.github.io/teal.picks/latest-tag/reference/index.html)
for full documentation.

Below is a minimal illustration of defining a `picks` specification
(datasets, then variables; optional
[`values()`](https://insightsengineering.github.io/teal.picks/reference/picks.md)
when needed):

``` r

library(teal.picks)

my_picks <- picks(
  datasets(choices = c("iris", "mtcars")),
  variables(
    choices = tidyselect::everything(),
    selected = 1L,
    multiple = TRUE
  )
)
```

Wire `my_picks` into **`picks_ui`** / **`picks_srv`** with a reactive
`teal_data` object, or use **`tm_merge`** inside a
**[`teal::init()`](https://insightsengineering.github.io/teal/latest-tag/reference/init.html)**
application. Full patterns are documented on the package site.

## Getting help

If you encounter a bug or have a feature request, please file an issue.
For questions, discussions, and staying up to date, please use the
`teal` channel in the [`pharmaverse` slack
workspace](https://pharmaverse.slack.com).

## Stargazers and Forkers

### Stargazers over time

[![Stargazers over
time](https://starchart.cc/insightsengineering/teal.picks.svg)](https://starchart.cc/insightsengineering/teal.picks)

### Stargazers

[![Stargazers repo roster for
@insightsengineering/teal.picks](http://reporoster.com/stars/insightsengineering/teal.picks)](https://github.com/insightsengineering/teal.picks/stargazers)

### Forkers

[![Forkers repo roster for
@insightsengineering/teal.picks](http://reporoster.com/forks/insightsengineering/teal.picks)](https://github.com/insightsengineering/teal.picks/network/members)
