test_that("two-year equal-profit example matches hand calculation", {
  # Base: year-1 profit 50 plus 50% * year-2 profit 50 = 75.
  # Alternative retention is 100%, so a permanent 12.5% discount gives
  # 37.5 profit in each year, or the same lifetime profit of 75.
  x <- equal_profit_discount(
    years = 2,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = 1,
    base_loss = 50,
    retention_vec_base = 0.50,
    retention_vec_alt = 1.00
  )

  expect_equal(x$base_pv_profit, 75)
  expect_equal(x$indicated_discount, 0.125)
  expect_equal(x$alt_pv_profit_after_discount, 75)
})
