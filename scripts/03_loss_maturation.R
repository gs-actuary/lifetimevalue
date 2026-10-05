# 03_loss_maturation.R
#
# Compare steep and gentle loss maturation. Both scenarios start with the same
# relatively high new-business loss cost and eventually reach the same mature
# loss level. The only difference is how quickly the excess new-business loss
# cost disappears.

library(lifetimevalue)

# Common assumptions -------------------------------------------------------
years <- 10
start_premium <- 1000
premium_rels <- rep(1, years)
base_loss <- 600  # mature annual expected loss
retention_base <- 0.75
retention_alt <- 0.85
fixed_expense_dollar <- c(300, rep(40, years - 1))
variable_expense_pct <- 0.18
pv_rate <- 0.04

loss_patterns <- list(
  Steep = c(1.30, 1.10, 1.03, rep(1.00, 7)),
  Gentle = c(1.30, 1.24, 1.18, 1.12, 1.06, rep(1.00, 5))
)

# Display the two loss-cost paths -----------------------------------------
loss_path_table <- data.frame(
  year = seq_len(years),
  steep_loss = base_loss * loss_patterns$Steep,
  gentle_loss = base_loss * loss_patterns$Gentle
)
print(loss_path_table, digits = 4)

matplot(
  loss_path_table$year,
  loss_path_table[c("steep_loss", "gentle_loss")],
  type = "b",
  pch = c(19, 1),
  lty = c(1, 2),
  xlab = "Projection year",
  ylab = "Expected loss ($)",
  main = "Steep vs. Gentle Loss Maturation"
)
legend(
  "topright",
  legend = c("Steep maturation", "Gentle maturation"),
  pch = c(19, 1),
  lty = c(1, 2),
  bty = "n"
)
grid()

# Compare the retention-supported discount under each loss pattern --------
results <- do.call(
  rbind,
  lapply(names(loss_patterns), function(pattern_name) {
    loss_rels_i <- loss_patterns[[pattern_name]]

    ans <- equal_profit_discount(
      years = years,
      start_premium = start_premium,
      premium_rels = premium_rels,
      loss_rels = loss_rels_i,
      base_loss = base_loss,
      retention_vec_base = retention_base,
      retention_vec_alt = retention_alt,
      fixed_expense_dollar = fixed_expense_dollar,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate
    )

    base_path <- build_ltv_path(
      years = years,
      start_premium = start_premium,
      premium_rels = premium_rels,
      loss_rels = loss_rels_i,
      base_loss = base_loss,
      retention_vec = retention_base,
      fixed_expense_dollar = fixed_expense_dollar,
      variable_expense_pct = variable_expense_pct,
      pv_rate = pv_rate
    )

    base_summary <- summarize_ltv(base_path)

    data.frame(
      loss_maturation = pattern_name,
      base_pv_profit = base_summary$pv_profit,
      base_lifetime_margin_pct = 100 * base_summary$lifetime_margin_pct,
      indicated_discount = ans$indicated_discount,
      indicated_discount_pct = 100 * ans$indicated_discount,
      stringsAsFactors = FALSE
    )
  })
)

rownames(results) <- NULL
cat("\nLifetime results under the two loss-maturation assumptions:\n")
print(results, digits = 4)
