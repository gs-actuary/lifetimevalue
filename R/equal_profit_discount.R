#' Solve for an equal-profit discount under alternative retention
#'
#' Calculates the premium discount or surcharge that makes an alternative
#' retention scenario produce the same present-value dollar profit as a base
#' retention scenario.
#'
#' @param years Positive integer number of projection years.
#' @param start_premium Nonnegative base starting premium.
#' @param premium_rels Numeric premium relativities by projection year.
#' @param loss_rels Numeric loss relativities by projection year.
#' @param base_loss Nonnegative base expected loss.
#' @param retention_vec_base Conditional renewal probabilities for the base
#'   scenario. Supply one value or a vector of length `years - 1`.
#' @param retention_vec_alt Conditional renewal probabilities for the alternative
#'   scenario. Supply one value or a vector of length `years - 1`.
#' @param fixed_expense_dollar Fixed expense dollars by projection year.
#' @param variable_expense_pct Variable expense as a proportion of premium by
#'   projection year.
#' @param pv_rate Annual present-value discount rate, using end-of-year timing.
#' @param discount_pattern Numeric vector describing how a unit discount is
#'   applied over time. A value of 1 means the full discount applies in that
#'   year, 0 means no discount, and intermediate values phase the discount out.
#'   A scalar is recycled to all years. The default is a permanent discount.
#'
#' @return A one-row base R `data.frame` containing base profit, alternative
#'   profit before and after the adjustment, the indicated discount, year-1
#'   premium effects, the minimum alternative premium, and a feasibility flag.
#'
#' @details
#' A positive `indicated_discount` means the alternative retention pattern can
#' support a lower premium while preserving expected present-value dollar profit.
#' A negative value is a surcharge: it can occur when additional retained years
#' are expected to be unprofitable.
#'
#' If `d` is the indicated discount and `m[t]` is `discount_pattern[t]`, the
#' alternative premium in year `t` is
#' `base_premium[t] * (1 - d * m[t])`. The alternative retention assumptions are
#' treated as fixed inputs; this function does not estimate retention elasticity
#' from the proposed price change.
#'
#' @examples
#' equal_profit_discount(
#'   years = 5,
#'   start_premium = 1000,
#'   premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
#'   loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
#'   base_loss = 700,
#'   retention_vec_base = c(0.80, 0.78, 0.75, 0.72),
#'   retention_vec_alt = c(0.88, 0.85, 0.82, 0.80),
#'   fixed_expense_dollar = c(80, 40, 40, 40, 40),
#'   variable_expense_pct = 0.20,
#'   pv_rate = 0.05
#' )
#'
#' # First-year-only discount
#' equal_profit_discount(
#'   years = 4,
#'   start_premium = 1000,
#'   premium_rels = 1,
#'   loss_rels = c(1.00, 0.95, 0.95, 0.95),
#'   base_loss = 700,
#'   retention_vec_base = 0.75,
#'   retention_vec_alt = 0.85,
#'   variable_expense_pct = 0.20,
#'   discount_pattern = c(1, 0, 0, 0)
#' )
#'
#' @export
equal_profit_discount <- function(
    years = 10,
    start_premium,
    premium_rels = rep(1, years),
    loss_rels,
    base_loss,
    retention_vec_base,
    retention_vec_alt,
    fixed_expense_dollar = 0,
    variable_expense_pct = 0,
    pv_rate = 0,
    discount_pattern = rep(1, years)
) {
  start_premium <- .validate_scalar(start_premium, "start_premium", lower = 0)

  a_base <- .prepare_ltv_assumptions(
    years = years,
    premium_rels = premium_rels,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention_vec_base,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate,
    retention_name = "retention_vec_base"
  )
  a_alt <- .prepare_ltv_assumptions(
    years = years,
    premium_rels = premium_rels,
    loss_rels = loss_rels,
    base_loss = base_loss,
    retention_vec = retention_vec_alt,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    pv_rate = pv_rate,
    retention_name = "retention_vec_alt"
  )

  discount_pattern <- .recycle_year(
    discount_pattern, a_base$years, "discount_pattern", lower = 0
  )
  if (all(discount_pattern == 0)) {
    stop("'discount_pattern' must be positive in at least one year.", call. = FALSE)
  }

  base_premium_path <- start_premium * a_base$premium_rels

  base_profit <- sum(
    a_base$weight *
      (base_premium_path * (1 - a_base$variable_expense_pct) -
         a_base$fixed_expense_dollar - a_base$loss)
  )

  alt_profit_before <- sum(
    a_alt$weight *
      (base_premium_path * (1 - a_alt$variable_expense_pct) -
         a_alt$fixed_expense_dollar - a_alt$loss)
  )

  discount_profit_coefficient <- sum(
    a_alt$weight * base_premium_path * discount_pattern *
      (1 - a_alt$variable_expense_pct)
  )

  if (!is.finite(discount_profit_coefficient) ||
      discount_profit_coefficient <= 0) {
    stop(
      "The discount has no positive premium-profit coefficient under the alternative scenario.",
      call. = FALSE
    )
  }

  indicated_discount <- (alt_profit_before - base_profit) /
    discount_profit_coefficient

  alt_premium_path <- base_premium_path *
    (1 - indicated_discount * discount_pattern)

  alt_profit_after <- sum(
    a_alt$weight *
      (alt_premium_path * (1 - a_alt$variable_expense_pct) -
         a_alt$fixed_expense_dollar - a_alt$loss)
  )

  data.frame(
    base_pv_profit = base_profit,
    alt_pv_profit_before_discount = alt_profit_before,
    alt_pv_profit_after_discount = alt_profit_after,
    indicated_discount = indicated_discount,
    year1_premium_base = base_premium_path[1L],
    year1_premium_alt = alt_premium_path[1L],
    year1_discount_dollar = base_premium_path[1L] - alt_premium_path[1L],
    min_premium_alt = min(alt_premium_path),
    feasible_nonnegative_premium = all(alt_premium_path >= 0),
    check.names = FALSE
  )
}
