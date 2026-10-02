# Pre-submission checklist

This file is excluded from the package build.

Before CRAN submission:

1. Replace the placeholder maintainer email in DESCRIPTION (`greg.sollenberger@example.com`) with the real maintainer email.
2. Confirm the intended license. The current draft uses MIT.
3. Add repository URL and BugReports fields after the public repository exists.
4. Run `devtools::document()` if roxygen2 is used to regenerate documentation.
5. Run `R CMD build` and `R CMD check --as-cran` on a system with R installed.
6. Run checks on Windows, macOS, and Linux if practical.
7. Spell-check DESCRIPTION, README, and Rd documentation.
