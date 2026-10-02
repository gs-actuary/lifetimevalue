\name{solve_ltv_premium}
\alias{solve_ltv_premium}
\title{Solve for a Starting Premium from a Lifetime Profitability Target}
\usage{
solve_ltv_premium(
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
)
}
\arguments{
\item{years}{Positive integer number of projection years.}
\item{premium_rels}{Numeric premium relativities by projection year. A scalar is recycled to all years.}
\item{loss_rels}{Numeric loss relativities by projection year. A scalar is recycled to all years.}
\item{base_loss}{Nonnegative numeric scalar giving the base expected loss.}
\item{retention_vec}{Conditional renewal probabilities. Supply either one probability or a vector of length \code{years - 1}. Year-1 survival is 1.}
\item{fixed_expense_dollar}{Fixed expense dollars by projection year.}
\item{variable_expense_pct}{Variable expense as a proportion of premium by projection year.}
\item{pv_rate}{Annual present-value discount rate, using end-of-year timing.}
\item{target_margin_pct}{Optional target lifetime profit margin, defined as present-value profit divided by present-value premium.}
\item{target_profit_dollar}{Optional target present-value profit in dollars.}
}
\value{
Numeric scalar giving the indicated starting premium.
}
\description{
Solves analytically for the starting premium required to achieve either a target present-value dollar profit or a target lifetime profit margin over a multi-year projection.
}
\details{
Exactly one of \code{target_margin_pct} and \code{target_profit_dollar} must be supplied. The solution is analytical because premium and variable expenses are linear in the starting premium.
}
\examples{
solve_ltv_premium(
  years = 5,
  premium_rels = c(1.00, 1.02, 1.04, 1.06, 1.08),
  loss_rels = c(1.00, 0.95, 0.95, 0.97, 1.00),
  base_loss = 700,
  retention_vec = c(0.85, 0.80, 0.78, 0.75),
  fixed_expense_dollar = c(80, 40, 40, 40, 40),
  variable_expense_pct = 0.20,
  pv_rate = 0.05,
  target_margin_pct = 0.05
)
}
