# 04_declining_new_business_discounts.R
#
# Translate temporary new-business discounts into equivalent LTV-based
# permanent discounts.
#
# Each new-business discount begins at policy age 0 and declines linearly
# to zero by policy age 5. For each schedule, we:
#   1. project lifetime profitability under the temporary discount;
#   2. solve for the constant premium that produces the same PV profit; and
#   3. express that constant premium reduction as the implied LTV discount.
#
# Thus, the "implied LTV discount" is the permanent discount that has the
# same lifetime economic cost as the temporary new-business discount.

library(lifetimevalue)

# Common assumptions -------------------------------------------------------
policy_age <- 0:10
years <- length(policy_age)
undiscounted_premium <- 1000

base_loss <- 620
loss_rels <- c(1.15, 1.10, 1.06, 1.03, 1.01, rep(1.00, 6))

# A scalar retention assumption is applied to each renewal transition.
# Year 1 / policy age 0 is automatically 100% in force.
retention <- 0.82

fixed_expense_dollar <- c(300, rep(40, years - 1))
variable_expense_pct <- 0.18
pv_rate <- 0.04

initial_discounts <- c(0.05, 0.10, 0.15)

# Temporary discount pattern ----------------------------------------------
# Example for a 15% initial discount:
# age 0: 15%
# age 1: 12%
# age 2:  9%
# age 3:  6%
# age 4:  3%
# age 5+: 0%
declining_discount <- function(initial_discount, policy_age) {
  initial_discount * pmax(1 - policy_age / 5, 0)
}

# Store scenario results ---------------------------------------------------
results <- vector("list", length(initial_discounts))
paths <- vector("list", length(initial_discounts))
names(paths) <- paste0(100 * initial_discounts, "% initial")

for (i in seq_along(initial_discounts)) {
  initial_discount <- initial_discounts[i]
  discount_path <- declining_discount(initial_discount, policy_age)

  # Project the actual temporary-discount scenario.
  temporary_path <- build_ltv_path(
    years = years,
    start_premium = undiscounted_premium,
    premium_rels = 1 - discount_path,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate
  )

  temporary_summary <- summarize_ltv(temporary_path)

  # Now solve for a single constant premium that produces exactly the same
  # lifetime PV profit. The difference from the undiscounted premium is the
  # implied permanent LTV-based discount.
  equivalent_level_premium <- solve_ltv_premium(
    years = years,
    premium_rels = 1,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate,
    target_profit_dollar = temporary_summary$pv_profit
  )

  implied_ltv_discount <- 1 - equivalent_level_premium / undiscounted_premium

  # Build the equivalent permanent-discount path as a check.
  equivalent_path <- build_ltv_path(
    years = years,
    start_premium = equivalent_level_premium,
    premium_rels = 1,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate
  )

  equivalent_summary <- summarize_ltv(equivalent_path)

  results[[i]] <- data.frame(
    initial_nb_discount_pct = 100 * initial_discount,
    implied_ltv_discount_pct = 100 * implied_ltv_discount,
    equivalent_level_premium = equivalent_level_premium,
    temporary_discount_pv_profit = temporary_summary$pv_profit,
    equivalent_level_pv_profit = equivalent_summary$pv_profit,
    profit_check_difference =
      equivalent_summary$pv_profit - temporary_summary$pv_profit,
    stringsAsFactors = FALSE
  )

  temporary_path$policy_age <- policy_age
  temporary_path$discount_pct <- 100 * discount_path
  temporary_path$scenario <- paste0(100 * initial_discount, "% initial")
  paths[[i]] <- temporary_path
}

results <- do.call(rbind, results)
rownames(results) <- NULL

# Display results ----------------------------------------------------------
cat("Temporary new-business discount paths (%):\n")
discount_table <- data.frame(policy_age = policy_age)
for (initial_discount in initial_discounts) {
  discount_table[[paste0("initial_", 100 * initial_discount, "pct")]] <-
    100 * declining_discount(initial_discount, policy_age)
}
print(discount_table, digits = 4)

cat("\nEquivalent LTV-based permanent discounts:\n")
print(results, digits = 5)

# The implied LTV discounts should be smaller than the initial discounts,
# because the temporary discounts run off while many retained policies remain
# in force and pay the full premium in later years.

# Plot 1: temporary discount schedules ------------------------------------
matplot(
  discount_table$policy_age,
  discount_table[-1],
  type = "b",
  pch = c(1, 2, 3),
  lty = c(1, 2, 3),
  xlab = "Policy age",
  ylab = "Premium discount (%)",
  main = "Temporary New-Business Discounts"
)
legend(
  "topright",
  legend = paste0(100 * initial_discounts, "% initial"),
  pch = c(1, 2, 3),
  lty = c(1, 2, 3),
  bty = "n"
)
grid()

# Plot 2: initial discount versus implied lifetime-equivalent discount -----
plot(
  results$initial_nb_discount_pct,
  results$implied_ltv_discount_pct,
  type = "b",
  pch = 19,
  xlab = "Initial new-business discount (%)",
  ylab = "Implied permanent LTV discount (%)",
  main = "Lifetime Cost of Temporary New-Business Discounts"
)
abline(a = 0, b = 1, lty = 2)
grid()

# Under these assumptions, the results are approximately:
#   5% initial discount  -> 2.6% implied permanent LTV discount
#  10% initial discount  -> 5.2% implied permanent LTV discount
#  15% initial discount  -> 7.8% implied permanent LTV discount
#
# These values depend on retention, expenses, loss maturation, discount rate,
# projection horizon, and the exact run-off pattern of the temporary discount.
