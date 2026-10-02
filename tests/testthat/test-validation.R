test_that("invalid retention inputs fail clearly", {
  expect_error(
    build_ltv_path(
      years = 3,
      start_premium = 100,
      premium_rels = 1,
      loss_rels = 1,
      base_loss = 50,
      retention_vec = c(0.8, 1.2)
    ),
    "between 0 and 1"
  )

  expect_error(
    build_ltv_path(
      years = 4,
      start_premium = 100,
      premium_rels = 1,
      loss_rels = 1,
      base_loss = 50,
      retention_vec = c(0.8, 0.7)
    ),
    "years - 1"
  )
})

test_that("premium solver requires exactly one target", {
  expect_error(
    solve_ltv_premium(
      years = 2,
      loss_rels = 1,
      base_loss = 50,
      retention_vec = 0.8
    ),
    "exactly one"
  )
})
