test_that("summary totals match the projected path", {
  x <- build_ltv_path(
    years = 4,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = 1,
    base_loss = 60,
    retention_vec = 0.8,
    fixed_expense_dollar = c(50, 5, 5, 5),
    variable_expense_pct = 0.1,
    pv_rate = 0.03
  )
  s <- summarize_ltv(x)

  expect_equal(s$pv_premium, sum(x$pv_premium))
  expect_equal(s$pv_profit, sum(x$pv_profit))
  expect_equal(s$expected_policy_years, sum(x$survival))
  expect_equal(s$lifetime_margin_pct, sum(x$pv_profit) / sum(x$pv_premium))
})
