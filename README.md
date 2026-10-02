# lifetimevalue

`lifetimevalue` is a small R package for deterministic insurance lifetime-value and asset-share-style pricing calculations. It projects the economics of an insurance policy across renewal years and makes the value of retention explicit.

The package is intentionally narrow and has **no runtime dependencies outside base R**.

## What it does

- `build_ltv_path()` projects premium, losses, expenses, retention, survival, profit, and discounted expected profit by year.
- `summarize_ltv()` reduces that path to present-value premium, losses, expenses, profit, lifetime margin, expected policy-years, and break-even year.
- `solve_ltv_premium()` solves analytically for a starting premium that achieves a target present-value dollar profit or lifetime profit margin.
- `equal_profit_discount()` solves for the discount or surcharge supported by an alternative retention pattern while holding present-value dollar profit constant.

The framework is closely related to the multi-period property/casualty asset share pricing approach discussed by Sholom Feldblum in *Asset Share Pricing for Property-Casualty Insurers*.

## Retention convention

A policy is assumed to be active with probability 1 in year 1. `retention_vec` contains **conditional renewal probabilities between policy years**.

For a four-year projection:

```r
retention_vec <- c(0.85, 0.80, 0.75)
```

implies survival probabilities of:

```text
Year 1: 1.000
Year 2: 0.850
Year 3: 0.680
Year 4: 0.510
```

A scalar retention assumption is recycled across renewal transitions.

## Basic projection

```r
library(lifetimevalue)

path <- build_ltv_path(
  years = 5,
  start_premium = 1000,
  premium_rels = c(1.00, 1.03, 1.05, 1.07, 1.10),
  loss_rels = c(1.00, 0.96, 0.94, 0.98, 1.01),
  base_loss = 700,
  retention_vec = c(0.85, 0.80, 0.78, 0.75),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = c(0.25, 0.20, 0.20, 0.20, 0.20),
  pv_rate = 0.05
)

path
summarize_ltv(path)
```

Amounts such as `premium`, `loss`, and `profit` are conditional on the policy being active in that year. `expected_*` columns weight them by policy survival; `pv_*` columns also discount them to present value.

## Solve for a lifetime target premium

```r
solve_ltv_premium(
  years = 5,
  premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
  loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
  base_loss = 700,
  retention_vec = c(0.85, 0.80, 0.78, 0.75),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = 0.20,
  pv_rate = 0.05,
  target_margin_pct = 0.05
)
```

`target_margin_pct` is defined as lifetime present-value profit divided by lifetime present-value premium. Instead of a margin, `target_profit_dollar` can specify a fixed present-value dollar target.

## Equal-profit retention discount

Suppose a second group is expected to retain better. The economic value of that retention can be expressed as the premium adjustment that leaves lifetime dollar profit unchanged.

```r
result <- equal_profit_discount(
  years = 5,
  start_premium = 1000,
  premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
  loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
  base_loss = 700,
  retention_vec_base = c(0.80, 0.78, 0.75, 0.72),
  retention_vec_alt = c(0.88, 0.85, 0.82, 0.80),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = 0.20,
  pv_rate = 0.05
)

result
```

A positive `indicated_discount` means the alternative retention pattern supports a lower premium at equal lifetime dollar profit. A negative value is a surcharge. That can occur when the additional renewal years are themselves unprofitable.

### Temporary discounts

The discount need not persist for the full lifetime. For a first-year-only acquisition discount:

```r
equal_profit_discount(
  years = 5,
  start_premium = 1000,
  premium_rels = 1,
  loss_rels = c(1.00, 0.95, 0.95, 0.95, 0.95),
  base_loss = 700,
  retention_vec_base = 0.75,
  retention_vec_alt = 0.85,
  variable_expense_pct = 0.20,
  discount_pattern = c(1, 0, 0, 0, 0)
)
```

A phased discount could use `c(1, 0.5, 0.25, 0, 0)`.

## Modeling scope

The package deliberately uses a deterministic annual expected-value framework. It does not estimate retention elasticity, model stochastic losses, calculate reserves, allocate capital, model taxes, or separately model claim-payment timing and investment income. Those assumptions can matter in a full pricing model, but they are outside the intended scope of this package.

Cash flow is discounted as though annual profit occurs at the end of each projection year.

## Development

Runtime dependencies: none.

Tests use `testthat` only as a suggested development dependency.
