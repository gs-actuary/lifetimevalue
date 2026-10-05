# 02_retention_sensitivity.R
#
# Show how the equal-profit discount changes with alternative retention.
# The first section fixes the base retention assumption at 75% and varies the
# alternative. The second asks how much a five-point retention improvement is
# worth at different starting retention levels.

library(lifetimevalue)

# Common assumptions -------------------------------------------------------
years <- 10
start_premium <- 1000
premium_rels <- rep(1, years)
loss_rels <- rep(1, years)
base_loss <- 650
fixed_expense_dollar <- c(300, rep(40, years - 1))
variable_expense_pct <- 0.18
pv_rate <- 0.04

# A. Vary the alternative retention assumption ----------------------------
retention_base <- 0.75
retention_alt_values <- c(0.75, 0.78, 0.80, 0.85, 0.90, 0.95)

results_alt <- do.call(
  rbind,
  lapply(retention_alt_values, function(retention_alt) {
    ans <- equal_profit_discount(
      years = years,
      start_premium = start_premium,
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
      retention_base = retention_base,
      retention_alt = retention_alt,
      retention_improvement_points = 100 * (retention_alt - retention_base),
      indicated_discount = ans$indicated_discount,
      indicated_discount_pct = 100 * ans$indicated_discount
    )
  })
)

rownames(results_alt) <- NULL
print(results_alt, digits = 4)

plot(
  100 * results_alt$retention_alt,
  results_alt$indicated_discount_pct,
  type = "b",
  pch = 19,
  xlab = "Alternative annual retention (%)",
  ylab = "Equal-profit discount (%)",
  main = "Discount Supported by Higher Retention"
)
grid()

# B. Hold the improvement at +5 percentage points -------------------------
retention_base_values <- c(0.60, 0.70, 0.80, 0.90)

results_five_point <- do.call(
  rbind,
  lapply(retention_base_values, function(retention_base_i) {
    retention_alt_i <- retention_base_i + 0.05

    ans <- equal_profit_discount(
      years = years,
      start_premium = start_premium,
      premium_rels = premium_rels,
      loss_rels = loss_rels,
      base_loss = base_loss,
      retention_vec_base = retention_base_i,
      retention_vec_alt = retention_alt_i,
      fixed_expense_dollar = fixed_expense_dollar,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate
    )

    data.frame(
      retention_base = retention_base_i,
      retention_alt = retention_alt_i,
      indicated_discount = ans$indicated_discount,
      indicated_discount_pct = 100 * ans$indicated_discount
    )
  })
)

rownames(results_five_point) <- NULL
cat("\nValue of a five-point retention improvement:\n")
print(results_five_point, digits = 4)
