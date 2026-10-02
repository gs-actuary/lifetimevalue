#' Summarize an insurance lifetime value projection
#'
#' Reduces a path produced by [build_ltv_path()] to key lifetime profitability
#' measures.
#'
#' @param path A data frame produced by [build_ltv_path()].
#'
#' @return A one-row base R `data.frame` containing present-value premium,
#'   losses, expenses, and profit; lifetime profit margin; expected policy-years;
#'   and the first projection year in which cumulative present-value profit is
#'   nonnegative.
#'
#' @examples
#' path <- build_ltv_path(
#'   years = 4,
#'   start_premium = 1000,
#'   premium_rels = 1,
#'   loss_rels = c(1.00, 0.96, 0.95, 0.98),
#'   base_loss = 700,
#'   retention_vec = 0.80,
#'   fixed_expense_dollar = c(150, 40, 40, 40),
#'   variable_expense_pct = 0.20,
#'   pv_rate = 0.04
#' )
#' summarize_ltv(path)
#'
#' @export
summarize_ltv <- function(path) {
  if (!is.data.frame(path)) {
    stop("'path' must be a data frame produced by build_ltv_path().", call. = FALSE)
  }

  required <- c(
    "year", "survival", "pv_premium", "pv_loss",
    "pv_variable_expense", "pv_fixed_expense", "pv_profit",
    "cumulative_pv_profit"
  )
  missing_cols <- setdiff(required, names(path))
  if (length(missing_cols) > 0L) {
    stop(sprintf(
      "'path' is missing required columns: %s.",
      paste(missing_cols, collapse = ", ")
    ), call. = FALSE)
  }

  if (nrow(path) == 0L) {
    stop("'path' must contain at least one projection year.", call. = FALSE)
  }

  pv_premium <- sum(path$pv_premium)
  pv_loss <- sum(path$pv_loss)
  pv_variable_expense <- sum(path$pv_variable_expense)
  pv_fixed_expense <- sum(path$pv_fixed_expense)
  pv_profit <- sum(path$pv_profit)
  margin <- if (pv_premium == 0) NA_real_ else pv_profit / pv_premium

  nonnegative <- which(path$cumulative_pv_profit >= 0)
  break_even_year <- if (length(nonnegative) == 0L) NA_integer_ else path$year[nonnegative[1L]]

  data.frame(
    pv_premium = pv_premium,
    pv_loss = pv_loss,
    pv_variable_expense = pv_variable_expense,
    pv_fixed_expense = pv_fixed_expense,
    pv_expense = pv_variable_expense + pv_fixed_expense,
    pv_profit = pv_profit,
    lifetime_margin_pct = margin,
    expected_policy_years = sum(path$survival),
    break_even_year = break_even_year,
    check.names = FALSE
  )
}
