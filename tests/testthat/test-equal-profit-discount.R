test_that("identical retention implies zero equal-profit discount", {
  x <- equal_profit_discount(
    years = 4,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = 1,
    base_loss = 60,
    retention_vec_base = 0.8,
    retention_vec_alt = 0.8
  )

  expect_equal(x$indicated_discount, 0, tolerance = 1e-12)
  expect_equal(x$base_pv_profit, x$alt_pv_profit_after_discount, tolerance = 1e-12)
})

test_that("alternative retention is repriced to equal dollar profit", {
  x <- equal_profit_discount(
    years = 5,
    start_premium = 1000,
    premium_rels = c(1, 1.02, 1.04, 1.06, 1.08),
    loss_rels = c(1, 0.95, 0.95, 0.97, 1),
    base_loss = 700,
    retention_vec_base = c(0.80, 0.78, 0.75, 0.72),
    retention_vec_alt = c(0.88, 0.85, 0.82, 0.80),
    fixed_expense_dollar = c(80, 40, 40, 40, 40),
    variable_expense_pct = 0.20,
    pv_rate = 0.05
  )

  expect_gt(x$indicated_discount, 0)
  expect_equal(x$base_pv_profit, x$alt_pv_profit_after_discount, tolerance = 1e-8)
})

test_that("first-year-only discount preserves equal profit", {
  x <- equal_profit_discount(
    years = 4,
    start_premium = 1000,
    premium_rels = 1,
    loss_rels = c(1, 0.95, 0.95, 0.95),
    base_loss = 700,
    retention_vec_base = 0.75,
    retention_vec_alt = 0.85,
    variable_expense_pct = 0.20,
    discount_pattern = c(1, 0, 0, 0)
  )

  expect_equal(x$base_pv_profit, x$alt_pv_profit_after_discount, tolerance = 1e-8)
  expect_gt(x$year1_discount_dollar, 0)
})

test_that("higher retention can imply a surcharge when renewals lose money", {
  x <- equal_profit_discount(
    years = 2,
    start_premium = 100,
    premium_rels = 1,
    loss_rels = c(0.5, 2.0),
    base_loss = 100,
    retention_vec_base = 0.2,
    retention_vec_alt = 0.9
  )

  expect_lt(x$indicated_discount, 0)
  expect_equal(x$base_pv_profit, x$alt_pv_profit_after_discount, tolerance = 1e-10)
})
