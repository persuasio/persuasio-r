# Debug Log — persuasio

Issues identified, investigated, and fixed during code review (2026-05-29).
Entries from the first pass focus on package setup, documentation, and wrapper
correctness. Entries from the second pass cover numerical cross-examination
against the Stata reference implementation (`persuasio-stata`).

Add new entries at the top. Format: date · function(s) · issue · status.

---

## [2026-05-29] Undocumented seed argument in persuasio4ytz

**Function:** `R/persuasio4ytz.R`, `man/persuasio4ytz.Rd`  
**Issue:** The `seed` parameter added to `persuasio4ytz()` was missing its
`@param` roxygen tag, causing `R CMD check` to report: *"Undocumented arguments
in Rd file 'persuasio4ytz.Rd': 'seed'"*.  
**Status:** Fixed — added `@param seed optional integer random seed for
bootstrap reproducibility` to the roxygen block; `man/persuasio4ytz.Rd`
regenerated via `devtools::document()`.

---

## Open items for future review

The following were identified but not yet addressed. Pick up in the next pass.

1. **Numerical comparison of bootstrap CIs** — structural alignment with Stata
   has been verified (separate loops, quantile levels), but no side-by-side
   numerical check on the same dataset has been run yet.
2. **Covariate interaction model edge cases** — `model = "interaction"` with
   small subgroups or collinear covariates has not been stress-tested.
3. **Missing value handling** — binary checks (`%in% c(0,1)`) fail silently
   when variables contain `NA` (since `NA %in% c(0,1)` is `FALSE`). Functions
   will stop with a misleading error rather than a clear NA message.
4. **`calc` via `persuasio()` summary statistics** — currently `persuasio(est
   = "calc")` derives group means from a data frame. It cannot yet accept
   pre-computed scalars (y1, y0, e1, e0) directly through the wrapper.

---

## [2026-05-29] persuasio4ytz bootstrap: joint vs independent resampling

**Function:** `R/persuasio4ytz.R`  
**Issue:** Stata runs two **independent** bootstrap calls — one for `aprlb`,
one for `aprub` — so lb and ub draws are uncorrelated. The R code used a single
joint loop (same resample for both), which is not compatible with Stata's
Bonferroni-based level correction (`bs_level = 1 - 2*alpha`).  
**Status:** Fixed — split into two separate independent loops, matching Stata's
structure. Quantile levels (`alpha` for lb, `1 - alpha` for ub) are unchanged.

---

## [2026-05-29] LPR bootstrap CI not clipped to [0, 1]

**Functions:** `R/persuasio4ytz2lpr.R`, `R/lpr4ytz.R`  
**Issue:** The normal-approximation CI was correctly clipped to [0, 1], but the
bootstrap CI used raw quantiles. Since LPR is a conditional probability bounded
in [0, 1], individual bootstrap draws can exceed 1 in finite samples, causing
the bootstrap CI upper to exceed 1 (README showed 1.8671). The Stata reference
(`persuasio4ytz2lpr.ado`) explicitly clips both normal and bootstrap CIs with
`max(0, ...)` and `min(1, ...)`.  
**Status:** Fixed — bootstrap quantiles clipped to [0, 1] in both
`persuasio4ytz2lpr.R` and `lpr4ytz.R`.

---

## [2026-05-29] persuasio4ytz bootstrap not reproducible — missing seed parameter

**Function:** `R/persuasio4ytz.R`  
**Issue:** The bootstrap branch called `set.seed(NULL)`, which explicitly
randomises the RNG state before the loop, overriding any seed set by the caller.
The sibling functions `persuasio4yz` and `persuasio4ytz2lpr` both accept a
`seed` argument; `persuasio4ytz` was the odd one out.  
**Status:** Fixed — removed `set.seed(NULL)`; added `seed = NULL` parameter
with `if (!is.null(seed)) set.seed(seed)`. The `persuasio()` wrapper passes
`seed` through automatically via `...`.

---

## [2026-05-29] Dead code in persuasio4ytz normal approximation

**Function:** `R/persuasio4ytz.R`  
**Issue:** Two variables (`grid` and `loss`) were computed but never used. They
were left over from an earlier grid-search approach to finding the Stoye (2009)
critical value, which was superseded by `optimize()`.  
**Status:** Fixed — deleted both assignments. Also added `suppressWarnings()`
around bootstrap `try()` calls in `persuasio4ytz.R`, `persuasio4ytz2lpr.R`, and
`persuasio4yz.R` to suppress expected NaN warnings from degenerate resamples.

---

## [2026-05-29] Missing space in binary-check error messages

**Functions:** `R/aprlb.R`, `R/aprub.R`, `R/lpr4ytz.R`  
**Issue:** `paste0(var, "must be binary")` produced messages like
`"voteddem_allmust be binary"` — no space between variable name and message.  
**Status:** Fixed — changed to `paste0(var, " must be binary")` in all seven
affected lines. Three regression tests added to `test-base_errors.R` to prevent
regression.

---

## [2026-05-29] persuasio() wrapper: wrong argument order for est = "yz"

**Function:** `R/persuasio.R`  
**Issue:** The most critical bug found in the first review pass. The wrapper
parsed every estimator as `c(y, t, z, x, ...)`. For `est = "yz"` (treatment
unobserved) this was wrong in two ways:
- `varlist = c(y, z)` errored because the wrapper looked for a missing third
  variable.
- `varlist = c(y, z, x)` silently passed the covariate as the instrument —
  a quiet wrong result.  

**Status:** Fixed — wrapper now parses `est = "yz"` as `c(y, z, x, ...)` and
all other estimators as `c(y, t, z, x, ...)`. Explicit `varlist` length checks
added for all four estimators. Regression tests added to `test-wrapper.R` and
`test-GKB.R`.

---

## [2026-05-29] Method argument not validated in inference wrappers

**Functions:** `R/persuasio4ytz.R`, `R/persuasio4ytz2lpr.R`, `R/persuasio4yz.R`  
**Issue:** Invalid `method` values (e.g. `method = "bayes"`) fell through
silently to confusing object construction rather than producing a clear error.  
**Status:** Fixed — added `match.arg(method, c("normal", "bootstrap"))` at the
top of each wrapper. Tests added to `test-base_errors.R`.

---

## [2026-05-29] DESCRIPTION and package metadata updates

**File:** `DESCRIPTION`, `inst/CITATION`, `NEWS.md`  
**Changes for CRAN readiness:**
- Version set to `0.1.0` (removes CRAN `Version contains large components` NOTE)
- `Authors@R` ordered correctly; Sokbae Lee set as maintainer (`cre`)
- Removed manual `Author`/`Maintainer` fields (generated from `Authors@R`)
- `Description` field refined to cover all data scenarios
- `inst/CITATION` added with full JPE citation for Jun and Lee (2023)
- `NEWS.md` updated to `0.1.0` with initial CRAN submission notes
- GitHub URLs for R and Stata repos added to `DESCRIPTION`

**Status:** Done. `R CMD check --as-cran --no-manual` passes with 2 environmental
NOTEs only (timestamp and URL resolution — both network/environment issues, not
package issues).

---

## [2026-05-29] Vignette renamed and revised for CRAN

**File:** `vignettes/getting-started.Rmd`  
**Changes:**
- Renamed from `persuasio.Rmd` to `getting-started.Rmd`; index entry updated
- Opening section rewritten to align with revised `DESCRIPTION`
- Replaced source-tree data loading with lazy data (`GKB` available after
  `library(persuasio)`)
- Bootstrap examples use `nboot = 100` and are evaluated during vignette
  build; surrounding prose notes that at least 1,000 replications are
  recommended for applied research
- Corrected wording for `yz` estimator, covariate models, inference wrappers,
  and standard-error availability
- Added Related Software and Reference sections

**Status:** Done. Vignette builds cleanly under `R CMD check`.
