test_that("dollar-profit premium solution reproduces target", {
  target <- 25
  p <- solve_ltv_premium(
    years = 5,
    premium_rels = c(1, 1.02, 1.04, 1.06, 1.08),
    loss_rels = c(1, 0.95, 0.95, 0.97, 1),
    base_loss = 700,
    retention_vec = c(0.85, 0.80, 0.78, 0.75),
    fixed_expense_dollar = c(80, 40, 40, 40, 40),
    variable_expense_pct = 0.20,
    pv_rate = 0.05,
    target_profit_dollar = target
  )

  path <- build_ltv_path(
    years = 5,
    start_premium = p,
    premium_rels = c(1, 1.02, 1.04, 1.06, 1.08),
    loss_rels = c(1, 0.95, 0.95, 0.97, 1),
    base_loss = 700,
    retention_vec = c(0.85, 0.80, 0.78, 0.75),
    fixed_expense_dollar = c(80, 40, 40, 40, 40),
    variable_expense_pct = 0.20,
    pv_rate = 0.05
  )

  expect_equal(sum(path$pv_profit), target, tolerance = 1e-8)
})

test_that("margin premium solution reproduces target", {
  target <- 0.05
  p <- solve_ltv_premium(
    years = 4,
    premium_rels = c(1, 1.02, 1.04, 1.06),
    loss_rels = c(1, 0.96, 0.95, 0.98),
    base_loss = 650,
    retention_vec = c(0.85, 0.80, 0.75),
    fixed_expense_dollar = c(80, 40, 40, 40),
    variable_expense_pct = 0.18,
    pv_rate = 0.04,
    target_margin_pct = target
  )

  path <- build_ltv_path(
    years = 4,
    start_premium = p,
    premium_rels = c(1, 1.02, 1.04, 1.06),
    loss_rels = c(1, 0.96, 0.95, 0.98),
    base_loss = 650,
    retention_vec = c(0.85, 0.80, 0.75),
    fixed_expense_dollar = c(80, 40, 40, 40),
    variable_expense_pct = 0.18,
    pv_rate = 0.04
  )
  s <- summarize_ltv(path)

  expect_equal(s$lifetime_margin_pct, target, tolerance = 1e-8)
})
