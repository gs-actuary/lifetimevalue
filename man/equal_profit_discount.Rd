\name{equal_profit_discount}
\alias{equal_profit_discount}
\title{Solve for an Equal-Profit Discount under Alternative Retention}
\usage{
equal_profit_discount(
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
)
}
\arguments{
\item{years}{Positive integer number of projection years.}
\item{start_premium}{Nonnegative base starting premium.}
\item{premium_rels}{Numeric premium relativities by projection year.}
\item{loss_rels}{Numeric loss relativities by projection year.}
\item{base_loss}{Nonnegative base expected loss.}
\item{retention_vec_base}{Conditional renewal probabilities for the base scenario. Supply one value or a vector of length \code{years - 1}.}
\item{retention_vec_alt}{Conditional renewal probabilities for the alternative scenario. Supply one value or a vector of length \code{years - 1}.}
\item{fixed_expense_dollar}{Fixed expense dollars by projection year.}
\item{variable_expense_pct}{Variable expense as a proportion of premium by projection year.}
\item{pv_rate}{Annual present-value discount rate, using end-of-year timing.}
\item{discount_pattern}{Numeric vector describing how a unit discount is applied over time. A value of 1 means the full discount applies in that year, 0 means no discount, and intermediate values phase the discount out. A scalar is recycled to all years. The default is a permanent discount.}
}
\value{
A one-row base R \code{data.frame} containing base profit, alternative profit before and after the adjustment, the indicated discount, year-1 premium effects, the minimum alternative premium, and a feasibility flag.
}
\description{
Calculates the premium discount or surcharge that makes an alternative retention scenario produce the same present-value dollar profit as a base retention scenario.
}
\details{
A positive \code{indicated_discount} means the alternative retention pattern can support a lower premium while preserving expected present-value dollar profit. A negative value is a surcharge: it can occur when additional retained years are expected to be unprofitable.

If \code{d} is the indicated discount and \code{m[t]} is \code{discount_pattern[t]}, the alternative premium in year \code{t} is \code{base_premium[t] * (1 - d * m[t])}. The alternative retention assumptions are treated as fixed inputs; this function does not estimate retention elasticity from the proposed price change.
}
\examples{
equal_profit_discount(
  years = 5,
  start_premium = 1000,
  premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
  loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
  base_loss = 700,
  retention_vec_base = c(0.80, 0.78, 0.75, 0.72),
  retention_vec_alt = c(0.88, 0.85, 0.82, 0.80),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = 0.20,
  pv_rate = 0.05
)
}
