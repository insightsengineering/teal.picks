# A method that should take a type and resolve it.

Generic that makes the minimal check on spec. Responsible of
subsetting/extract the data received and check that the type matches

## Usage

``` r
determine(x, data)
```

## Arguments

- x:

  The specification to resolve.

- data:

  The minimal data required.

## Value

A list with two elements, the `type` resolved and the data extracted.
