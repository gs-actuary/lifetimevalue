#' Build an insurance lifetime value path
#'
#' Constructs a year-by-year deterministic projection of premium, expected
#' losses, expenses, policy survival, profit, and discounted expected profit.
#'
#' @param years Positive integer number of projection years.
#' @param start_premium Nonnegative numeric scalar giving the starting premium.
#' @param premium_rels Numeric premium relativities by projection year. A scalar
#'   is recycled to all years.
#' @param loss_rels Numeric loss relativities by projection year. A scalar is
#'   recycled to all years.
#' @param base_loss Nonnegative numeric scalar giving the base expected loss.
#' @param retention_vec Conditional renewal probabilities. Supply either one
#'   probability to use between every pair of projection years or a vector of
#'   length `years - 1`. The policy is assumed to be in force with probability
#'   1 in year 1; the first element is the probability of reaching year 2.
#' @param fixed_expense_dollar Fixed expense dollars by projection year. A
#'   scalar is recycled to all years.
#' @param variable_expense_pct Variable expense as a proportion of premium by
#'   projection year. A scalar is recycled to all years.
#' @param pv_rate Annual present-value discount rate. Cash flow is assumed to
#'   occur at the end of each projection year.
#'
#' @return A base R `data.frame` with one row per projection year. Conditional
#'   policy-year amounts are accompanied by survival-weighted expected amounts,
#'   present values, and cumulative present-value profit.
#'
#' @details
#' `premium`, `loss`, `variable_expense`, `fixed_expense`, and `profit` are
#' amounts conditional on the policy being active in that projection year.
#' Columns beginning with `expected_` multiply those conditional amounts by the
#' probability that the original policy survives to that year. Columns beginning
#' with `pv_` additionally apply the end-of-year present-value factor.
#'
#' The function intentionally uses an annual deterministic projection. It does
#' not model claim-payment timing within a year, capital, taxes, or stochastic
#' variation.
#'
#' @examples
#' path <- build_ltv_path(
#'   years = 5,
#'   start_premium = 1000,
#'   premium_rels = c(1.00, 1.03, 1.05, 1.07, 1.10),
#'   loss_rels = c(1.00, 0.96, 0.94, 0.98, 1.01),
#'   base_loss = 700,
#'   retention_vec = c(0.85, 0.80, 0.78, 0.75),
#'   fixed_expense_dollar = c(80, 40, 40, 40, 40),
#'   variable_expense_pct = c(0.25, 0.20, 0.20, 0.20, 0.20),
#'   pv_rate = 0.05
#' )
#' path
#'
#' @export
build_ltv_path <- function(
    years = 10,
    start_premium,
    premium_rels = rep(1, years),
    loss_rels,
    base_loss,
    retention_vec,
    fixed_expense_dollar = 0,
    variable_expense_pct = 0,
    pv_rate = 0
) {
  start_premium <- .validate_scalar(start_premium, "start_premium", lower = 0)

  a <- .prepare_ltv_assumptions(
    years = years,
    premium_rels = premium_rels,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention_vec,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate
  )

  premium <- start_premium * a$premium_rels
  loss <- a$loss
  variable_expense <- premium * a$variable_expense_pct
  fixed_expense <- a$fixed_expense_dollar
  profit <- premium - variable_expense - fixed_expense - loss

  expected_premium <- premium * a$survival
  expected_loss <- loss * a$survival
  expected_variable_expense <- variable_expense * a$survival
  expected_fixed_expense <- fixed_expense * a$survival
  expected_profit <- profit * a$survival

  pv_premium <- expected_premium * a$pv_factor
  pv_loss <- expected_loss * a$pv_factor
  pv_variable_expense <- expected_variable_expense * a$pv_factor
  pv_fixed_expense <- expected_fixed_expense * a$pv_factor
  pv_profit <- expected_profit * a$pv_factor

  data.frame(
    year = a$year,
    premium = premium,
    loss = loss,
    variable_expense = variable_expense,
    fixed_expense = fixed_expense,
    profit = profit,
    survival = a$survival,
    pv_factor = a$pv_factor,
    expected_premium = expected_premium,
    expected_loss = expected_loss,
    expected_variable_expense = expected_variable_expense,
    expected_fixed_expense = expected_fixed_expense,
    expected_profit = expected_profit,
    pv_premium = pv_premium,
    pv_loss = pv_loss,
    pv_variable_expense = pv_variable_expense,
    pv_fixed_expense = pv_fixed_expense,
    pv_profit = pv_profit,
    cumulative_pv_profit = cumsum(pv_profit),
    check.names = FALSE
  )
}
