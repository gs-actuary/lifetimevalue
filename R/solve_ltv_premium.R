#' Solve for a starting premium from a lifetime profitability target
#'
#' Solves analytically for the starting premium required to achieve either a
#' target present-value dollar profit or a target lifetime profit margin over a
#' multi-year projection.
#'
#' @param years Positive integer number of projection years.
#' @param premium_rels Numeric premium relativities by projection year. A scalar
#'   is recycled to all years.
#' @param loss_rels Numeric loss relativities by projection year. A scalar is
#'   recycled to all years.
#' @param base_loss Nonnegative numeric scalar giving the base expected loss.
#' @param retention_vec Conditional renewal probabilities. Supply either one
#'   probability or a vector of length `years - 1`. Year-1 survival is 1.
#' @param fixed_expense_dollar Fixed expense dollars by projection year.
#' @param variable_expense_pct Variable expense as a proportion of premium by
#'   projection year.
#' @param pv_rate Annual present-value discount rate, using end-of-year timing.
#' @param target_margin_pct Optional target lifetime profit margin, defined as
#'   present-value profit divided by present-value premium.
#' @param target_profit_dollar Optional target present-value profit in dollars.
#'
#' @return Numeric scalar giving the indicated starting premium.
#'
#' @details
#' Exactly one of `target_margin_pct` and `target_profit_dollar` must be supplied.
#' The solution is analytical because premium and variable expenses are linear
#' in the starting premium.
#'
#' @examples
#' solve_ltv_premium(
#'   years = 5,
#'   premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
#'   loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
#'   base_loss = 700,
#'   retention_vec = c(0.85, 0.80, 0.78, 0.75),
#'   fixed_expense_dollar = c(80, 40, 40, 40, 40),
#'   variable_expense_pct = 0.20,
#'   pv_rate = 0.05,
#'   target_margin_pct = 0.05
#' )
#'
#' @export
solve_ltv_premium <- function(
    years = 10,
    premium_rels = rep(1, years),
    loss_rels,
    base_loss,
    retention_vec,
    fixed_expense_dollar = 0,
    variable_expense_pct = 0,
    pv_rate = 0,
    target_margin_pct = NULL,
    target_profit_dollar = NULL
) {
  if (!xor(is.null(target_margin_pct), is.null(target_profit_dollar))) {
    stop(
      "Specify exactly one of 'target_margin_pct' or 'target_profit_dollar'.",
      call. = FALSE
    )
  }

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

  net_premium_coefficient <- sum(
    a$weight * a$premium_rels * (1 - a$variable_expense_pct)
  )
  pv_premium_coefficient <- sum(a$weight * a$premium_rels)
  nonpremium_cost <- sum(a$weight * (a$loss + a$fixed_expense_dollar))

  if (!is.null(target_margin_pct)) {
    target_margin_pct <- .validate_scalar(target_margin_pct, "target_margin_pct")
    denominator <- net_premium_coefficient -
      target_margin_pct * pv_premium_coefficient
    if (!is.finite(denominator) || denominator <= 0) {
      stop(
        "No positive premium solution exists for the requested target margin under these assumptions.",
        call. = FALSE
      )
    }
    indicated <- nonpremium_cost / denominator
  } else {
    target_profit_dollar <- .validate_scalar(
      target_profit_dollar, "target_profit_dollar"
    )
    if (!is.finite(net_premium_coefficient) || net_premium_coefficient <= 0) {
      stop(
        "No positive premium solution exists because the coefficient on premium is not positive.",
        call. = FALSE
      )
    }
    indicated <- (target_profit_dollar + nonpremium_cost) /
      net_premium_coefficient
  }

  if (!is.finite(indicated) || indicated < 0) {
    stop(
      "The requested profitability target does not imply a nonnegative starting premium.",
      call. = FALSE
    )
  }

  as.numeric(indicated)
}
