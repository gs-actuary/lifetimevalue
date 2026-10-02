# lifetimevalue 0.1.0

- Initial package structure.
- Added `build_ltv_path()` for annual deterministic lifetime-value projections.
- Added `summarize_ltv()` for lifetime present-value profitability summaries.
- Added `solve_ltv_premium()` for analytical target-profit and target-margin premium solutions.
- Added `equal_profit_discount()` for retention-sensitive equal-dollar-profit discounts or surcharges, including temporary and phased discount patterns.
- Defined retention as conditional renewal probability between policy years, with year-1 survival equal to 1.
- Removed all runtime package dependencies; outputs are base R data frames.
