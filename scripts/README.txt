lifetimevalue showcase scripts
==============================

01_expense_front_loading.R
  Holds total nominal fixed expense constant and shows how more first-year
  acquisition expense changes the discount supported by better retention.

02_retention_sensitivity.R
  Varies the alternative retention assumption, then separately shows the value
  of a fixed five-percentage-point improvement at different base retention
  levels.

03_loss_maturation.R
  Compares rapid versus gradual maturation from high new-business losses to the
  same mature loss level, including the resulting equal-profit discount.

04_declining_new_business_discounts.R
  Compares 5%, 10%, and 15% issue-time discounts that run off linearly to zero
  by policy age 5, and shows their cumulative lifetime profitability paths.

05_profit_target_sensitivity.R
  Solves the base premium for lifetime PV profit targets of $0, $100, $200,
  $300, $500, and $1,000, then shows the equal-profit discount supported by
  better retention at each target.

All scripts use only base R plus lifetimevalue.
