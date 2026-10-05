# 01_expense_front_loading.R
#
# Show how the equal-profit discount changes as expenses become more
# front-loaded. Total nominal fixed expense is held constant across scenarios,
# so the only thing changing is the split between first-year and renewal costs.

library(lifetimevalue)

# Common assumptions -------------------------------------------------------
years <- 10
start_premium <- 1000
premium_rels <- rep(1, years)
loss_rels <- rep(1, years)
base_loss <- 650
retention_base <- 0.75
retention_alt <- 0.85
variable_expense_pct <- 0.18
pv_rate <- 0.04

total_fixed_expense <- 800

# Every profile below sums to the same $800 of nominal fixed expense.
expense_profiles <- list(
  Flat = rep(total_fixed_expense / years, years),
  Moderate = c(
    200,
    rep((total_fixed_expense - 200) / (years - 1), years - 1)
  ),
  Steep = c(
    400,
    rep((total_fixed_expense - 400) / (years - 1), years - 1)
  ),
  Very_steep = c(
    600,
    rep((total_fixed_expense - 600) / (years - 1), years - 1)
  )
)

results <- do.call(
  rbind,
  lapply(names(expense_profiles), function(profile_name) {
    expenses <- expense_profiles[[profile_name]]

    ans <- equal_profit_discount(
      years = years,
      start_premium = start_premium,
      premium_rels = premium_rels,
      loss_rels = loss_rels,
      base_loss = base_loss,
      retention_vec_base = retention_base,
      retention_vec_alt = retention_alt,
      fixed_expense_dollar = expenses,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate
    )

    data.frame(
      expense_profile = profile_name,
      first_year_fixed_expense = expenses[1],
      renewal_fixed_expense = expenses[2],
      total_nominal_fixed_expense = sum(expenses),
      indicated_discount = ans$indicated_discount,
      indicated_discount_pct = 100 * ans$indicated_discount,
      base_pv_profit = ans$base_pv_profit,
      stringsAsFactors = FALSE
    )
  })
)

rownames(results) <- NULL
print(results, digits = 4)

# More front-loaded acquisition expense makes additional retained renewal years
# more valuable because those later years carry less fixed expense.
plot(
  results$first_year_fixed_expense,
  results$indicated_discount_pct,
  type = "b",
  pch = 19,
  xlab = "First-year fixed expense ($)",
  ylab = "Equal-profit discount (%)",
  main = "Value of Retention vs. Expense Front-Loading"
)
grid()
