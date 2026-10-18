# Typed calculator

A compact tour of PureScript's type-level and abstraction features:

- an algebraic data type for expressions and a total evaluator returning
  `Either String Int`
- a `Pretty` type class for rendering expressions
- a `Prism'` built with `prism'` and used through `preview`
- a row-typed `Variant` for binary operators, matched exhaustively with `match`
- an open row type for configuration records
- `spec` tests and QuickCheck properties

## Run

```sh
spago run
```

## Test

```sh
spago test
```

The suite contains two example tests and two QuickCheck properties. The
`spec-node` test runner exits with a non-zero code when a test fails.
