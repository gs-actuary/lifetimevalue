.validate_years <- function(years) {
  if (length(years) != 1L || !is.numeric(years) || !is.finite(years) ||
      years < 1 || years != as.integer(years)) {
    stop("'years' must be a single positive integer.", call. = FALSE)
  }
  as.integer(years)
}

.validate_scalar <- function(x, name, lower = -Inf, strict_lower = FALSE) {
  if (length(x) != 1L || !is.numeric(x) || !is.finite(x)) {
    stop(sprintf("'%s' must be a single finite numeric value.", name), call. = FALSE)
  }
  bad <- if (strict_lower) x <= lower else x < lower
  if (bad) {
    op <- if (strict_lower) ">" else ">="
    stop(sprintf("'%s' must be %s %s.", name, op, lower), call. = FALSE)
  }
  as.numeric(x)
}

.recycle_year <- function(x, years, name, lower = -Inf) {
  if (!is.numeric(x) || length(x) == 0L || any(!is.finite(x))) {
    stop(sprintf("'%s' must contain finite numeric values.", name), call. = FALSE)
  }
  if (length(x) == 1L) {
    x <- rep(x, years)
  } else if (length(x) != years) {
    stop(sprintf("'%s' must have length 1 or length %s.", name, years), call. = FALSE)
  }
  if (any(x < lower)) {
    stop(sprintf("'%s' must contain values >= %s.", name, lower), call. = FALSE)
  }
  as.numeric(x)
}

.retention_survival <- function(retention_vec, years, name = "retention_vec") {
  if (years == 1L) {
    if (!is.numeric(retention_vec) || length(retention_vec) != 1L ||
        any(!is.finite(retention_vec))) {
      stop(sprintf("'%s' must be a single finite probability when years = 1.", name), call. = FALSE)
    }
    if (any(retention_vec < 0 | retention_vec > 1)) {
      stop(sprintf("'%s' must contain probabilities between 0 and 1.", name), call. = FALSE)
    }
    return(1)
  }

  if (!is.numeric(retention_vec) || length(retention_vec) == 0L ||
      any(!is.finite(retention_vec))) {
    stop(sprintf("'%s' must contain finite numeric values.", name), call. = FALSE)
  }

  if (length(retention_vec) == 1L) {
    retention_vec <- rep(retention_vec, years - 1L)
  } else if (length(retention_vec) != years - 1L) {
    stop(sprintf(
      "'%s' must have length 1 or length years - 1 (%s).",
      name, years - 1L
    ), call. = FALSE)
  }

  if (any(retention_vec < 0 | retention_vec > 1)) {
    stop(sprintf("'%s' must contain probabilities between 0 and 1.", name), call. = FALSE)
  }

  c(1, cumprod(retention_vec))
}

.prepare_ltv_assumptions <- function(
    years,
    premium_rels,
    loss_rels,
    base_loss,
    retention_vec,
    fixed_expense_dollar,
    variable_expense_pct,
    pv_rate,
    retention_name = "retention_vec"
) {
  years <- .validate_years(years)
  base_loss <- .validate_scalar(base_loss, "base_loss", lower = 0)
  pv_rate <- .validate_scalar(pv_rate, "pv_rate", lower = -1, strict_lower = TRUE)

  premium_rels <- .recycle_year(premium_rels, years, "premium_rels", lower = 0)
  loss_rels <- .recycle_year(loss_rels, years, "loss_rels", lower = 0)
  fixed_expense_dollar <- .recycle_year(
    fixed_expense_dollar, years, "fixed_expense_dollar"
  )
  variable_expense_pct <- .recycle_year(
    variable_expense_pct, years, "variable_expense_pct", lower = 0
  )
  survival <- .retention_survival(retention_vec, years, retention_name)
  year <- seq_len(years)
  pv_factor <- 1 / (1 + pv_rate) ^ year

  list(
    years = years,
    year = year,
    premium_rels = premium_rels,
    loss_rels = loss_rels,
    base_loss = base_loss,
    loss = base_loss * loss_rels,
    fixed_expense_dollar = fixed_expense_dollar,
    variable_expense_pct = variable_expense_pct,
    survival = survival,
    pv_rate = pv_rate,
    pv_factor = pv_factor,
    weight = survival * pv_factor
  )
}
