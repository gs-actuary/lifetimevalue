test_that("year-1 survival is one and retention compounds thereafter", {
  x <- build_ltv_path(
    years = 4,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = 1,
    base_loss = 50,
    retention_vec = c(0.8, 0.75, 0.5)
  )

  expect_equal(x$survival, c(1, 0.8, 0.6, 0.3))
})

test_that("scalar projection inputs recycle", {
  x <- build_ltv_path(
    years = 3,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = 1,
    base_loss = 50,
    retention_vec = 0.8,
    fixed_expense_dollar = 10,
    variable_expense_pct = 0.1
  )

  expect_equal(x$premium, rep(100, 3))
  expect_equal(x$loss, rep(50, 3))
  expect_equal(x$fixed_expense, rep(10, 3))
  expect_equal(x$variable_expense, rep(10, 3))
})

test_that("present-value profit reconciles to components", {
  x <- build_ltv_path(
    years = 3,
    start_premium = 100,
    premium_rels = c(1, 1.1, 1.2),
    loss_rels = c(1, 0.9, 0.8),
    base_loss = 60,
    retention_vec = c(0.8, 0.7),
    fixed_expense_dollar = c(10, 5, 5),
    variable_expense_pct = 0.1,
    pv_rate = 0.05
  )

  expect_equal(
    x$pv_profit,
    x$pv_premium - x$pv_loss - x$pv_variable_expense - x$pv_fixed_expense
  )
  expect_equal(x$cumulative_pv_profit, cumsum(x$pv_profit))
})
