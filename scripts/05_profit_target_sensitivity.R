# 05_profit_target_sensitivity.R
#
# Show how the equal-profit retention discount changes with the assumed
# lifetime dollar profit target: $0, $100, $200, $300, $500, and $1,000.
#
# The requested values are dollar profit targets rather than profit-margin
# percentages, so this example uses target_profit_dollar. For each target:
#   1. solve_ltv_premium() finds the base premium that achieves that profit;
#   2. equal_profit_discount() finds the discount supported by better retention
#      while preserving the same dollar profit.

library(lifetimevalue)

# Common assumptions -------------------------------------------------------
years <- 10
premium_rels <- rep(1, years)
loss_rels <- rep(1, years)
base_loss <- 650
retention_base <- 0.75
retention_alt <- 0.85
fixed_expense_dollar <- c(300, rep(40, years - 1))
variable_expense_pct <- 0.18
pv_rate <- 0.04
profit_targets <- c(0, 100, 200, 300, 500, 1000)

results <- do.call(
  rbind,
  lapply(profit_targets, function(target_profit) {
    required_base_premium <- solve_ltv_premium(
      years = years,
      premium_rels = premium_rels,
      loss_rels = loss_rels,
      base_loss = base_loss,
      retention_vec = retention_base,
      fixed_expense_dollar = fixed_expense_dollar,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate,
      target_profit_dollar = target_profit
    )

    ans <- equal_profit_discount(
      years = years,
      start_premium = required_base_premium,
      premium_rels = premium_rels,
      loss_rels = loss_rels,
      base_loss = base_loss,
      retention_vec_base = retention_base,
      retention_vec_alt = retention_alt,
      fixed_expense_dollar = fixed_expense_dollar,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate
    )

    data.frame(
      target_pv_profit = target_profit,
      required_base_premium = required_base_premium,
      indicated_discount = ans$indicated_discount,
      indicated_discount_pct = 100 * ans$indicated_discount,
      alternative_year1_premium = ans$year1_premium_alt,
      check_alt_pv_profit = ans$alt_pv_profit_after_discount
    )
  })
)

rownames(results) <- NULL
print(results, digits = 4)

plot(
  results$target_pv_profit,
  results$indicated_discount_pct,
  type = "b",
  pch = 19,
  xlab = "Target lifetime PV profit ($)",
  ylab = "Equal-profit discount (%)",
  main = "Retention Discount vs. Profit Target"
)
grid()
