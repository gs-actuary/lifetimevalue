\name{summarize_ltv}
\alias{summarize_ltv}
\title{Summarize an Insurance Lifetime Value Projection}
\usage{
summarize_ltv(path)
}
\arguments{
\item{path}{A data frame produced by \code{build_ltv_path()}.}
}
\value{
A one-row base R \code{data.frame} containing present-value premium, losses, expenses, and profit; lifetime profit margin; expected policy-years; and the first projection year in which cumulative present-value profit is nonnegative.
}
\description{
Reduces a path produced by \code{build_ltv_path()} to key lifetime profitability measures.
}
\examples{
path <- build_ltv_path(
  years = 4,
  start_premium = 1000,
  premium_rels = 1,
  loss_rels = c(1.00, 0.96, 0.95, 0.98),
  base_loss = 700,
  retention_vec = 0.80,
  fixed_expense_dollar = c(150, 40, 40, 40),
  variable_expense_pct = 0.20,
  pv_rate = 0.04
)
summarize_ltv(path)
}
