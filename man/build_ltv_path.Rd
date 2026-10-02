\name{build_ltv_path}
\alias{build_ltv_path}
\title{Build an Insurance Lifetime Value Path}
\usage{
build_ltv_path(
  years = 10,
  start_premium,
  premium_rels = rep(1, years),
  loss_rels,
  base_loss,
  retention_vec,
  fixed_expense_dollar = 0,
  variable_expense_pct = 0,
  pv_rate = 0
)
}
\arguments{
\item{years}{Positive integer number of projection years.}
\item{start_premium}{Nonnegative numeric scalar giving the starting premium.}
\item{premium_rels}{Numeric premium relativities by projection year. A scalar is recycled to all years.}
\item{loss_rels}{Numeric loss relativities by projection year. A scalar is recycled to all years.}
\item{base_loss}{Nonnegative numeric scalar giving the base expected loss.}
\item{retention_vec}{Conditional renewal probabilities. Supply either one probability to use between every pair of projection years or a vector of length \code{years - 1}. The policy is assumed to be in force with probability 1 in year 1; the first element is the probability of reaching year 2.}
\item{fixed_expense_dollar}{Fixed expense dollars by projection year. A scalar is recycled to all years.}
\item{variable_expense_pct}{Variable expense as a proportion of premium by projection year. A scalar is recycled to all years.}
\item{pv_rate}{Annual present-value discount rate. Cash flow is assumed to occur at the end of each projection year.}
}
\value{
A base R \code{data.frame} with one row per projection year. Conditional policy-year amounts are accompanied by survival-weighted expected amounts, present values, and cumulative present-value profit.
}
\description{
Constructs a year-by-year deterministic projection of premium, expected losses, expenses, policy survival, profit, and discounted expected profit.
}
\details{
\code{premium}, \code{loss}, \code{variable_expense}, \code{fixed_expense}, and \code{profit} are amounts conditional on the policy being active in that projection year. Columns beginning with \code{expected_} multiply those conditional amounts by the probability that the original policy survives to that year. Columns beginning with \code{pv_} additionally apply the end-of-year present-value factor.

The function intentionally uses an annual deterministic projection. It does not model claim-payment timing within a year, capital, taxes, or stochastic variation.
}
\examples{
path <- build_ltv_path(
  years = 5,
  start_premium = 1000,
  premium_rels = c(1.00, 1.03, 1.05, 1.07, 1.10),
  loss_rels = c(1.00, 0.96, 0.94, 0.98, 1.01),
  base_loss = 700,
  retention_vec = c(0.85, 0.80, 0.78, 0.75),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = c(0.25, 0.20, 0.20, 0.20, 0.20),
  pv_rate = 0.05
)
path
}
