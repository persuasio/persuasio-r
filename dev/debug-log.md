# Debug Log — persuasio

Log of known issues, investigations, and fixes. Add new entries at the top.
Format: date · function(s) · description · status.

---

## [2026-05-29] persuasio4ytz bootstrap: joint resampling vs Stata separate bootstrap

**Function:** `R/persuasio4ytz.R` (bootstrap branch)  
**Issue:** Stata runs two **independent** bootstrap calls — one for `aprlb`, one
for `aprub` — so lb and ub draws are uncorrelated. The original R code used a
**single joint loop** (same resample for both lb and ub). The Bonferroni-based
level correction in Stata (`bs_level = 1 - 2*alpha`) is designed for the
independent case; the joint loop produces results that are not directly
comparable.  
**Fix:** Split into two separate loops, matching Stata's structure exactly.
The quantile levels (`alpha` for lb, `1 - alpha` for ub) are unchanged.  
**Status:** Fixed 2026-05-29 — split joint loop into separate lb and ub loops
in `persuasio4ytz.R`. All 17 wrapper tests pass.

---

## [2026-05-29] Bootstrap CI not clipped to [0, 1] in persuasio4ytz2lpr

**Function:** `R/persuasio4ytz2lpr.R` (bootstrap branch, lines 176–177)  
**Issue:** The normal-approximation CI is correctly clipped to [0, 1], but the
bootstrap CI uses raw quantiles and is not clipped. Since LPR is a conditional
probability bounded in [0, 1], individual bootstrap draws can exceed 1 in finite
samples and bleed into the quantile-based interval. The README example already
shows a bootstrap CI upper of 1.8671.  
The base function `lpr4ytz` (lines 149–150) also returns unclipped CIs when
called directly.  
**Fix needed:** Clip bootstrap quantiles to [0, 1] in `persuasio4ytz2lpr`;
similarly clip in `lpr4ytz`.  
**Status:** Fixed 2026-05-29 — clipped bootstrap quantiles in `persuasio4ytz2lpr.R`
(lines 176–177) and direct CI in `lpr4ytz.R` (lines 149–150) to `[0, 1]`,
matching Stata reference implementation (`persuasio4ytz2lpr.ado`).

---

## [2026-05-29] Missing seed parameter in persuasio4ytz — bootstrap not reproducible

**Function:** `R/persuasio4ytz.R` (line 184)  
**Issue:** The bootstrap branch calls `set.seed(NULL)`, which explicitly
randomises the RNG state. Unlike sibling functions `persuasio4yz` and
`persuasio4ytz2lpr`, which both accept a `seed` argument, `persuasio4ytz` offers
no way to get reproducible bootstrap results.  
**Fix needed:** Remove `set.seed(NULL)`; add a `seed = NULL` parameter and call
`if (!is.null(seed)) set.seed(seed)` at the top of the function, consistent with
the other inference wrappers.  
**Status:** Fixed 2026-05-29 — added `seed = NULL` parameter to `persuasio4ytz`,
replaced `set.seed(NULL)` with `if (!is.null(seed)) set.seed(seed)`. The
`persuasio()` wrapper passes `seed` through automatically via `...`. Two
regression tests added to `test-wrapper.R`; all 17 wrapper tests now pass.

---

## [2026-05-29] Dead code in persuasio4ytz — grid and loss never used

**Function:** `R/persuasio4ytz.R` (lines 146–150)  
**Issue:** `grid` and `loss` are computed but never referenced. The actual
critical value comes from `optimize()` on line 156. These appear to be leftover
from an earlier grid-search approach that was superseded.  
**Fix needed:** Delete the two unused assignments.  
**Status:** Fixed 2026-05-29 — deleted `grid` and `loss` from `persuasio4ytz.R`.
Also added `suppressWarnings()` around all bootstrap `try()` calls in
`persuasio4ytz.R`, `persuasio4ytz2lpr.R`, and `persuasio4yz.R` to suppress
expected NaN warnings from degenerate resamples. All 17 wrapper tests now pass
with 0 warnings.

---

## [2026-05-29] Missing space in binary-check error messages

**Functions:** `R/aprlb.R` (lines 65–66), `R/aprub.R` (lines 67–69),
`R/lpr4ytz.R` (lines 83–85)  
**Issue:** All binary input checks use `paste0(var, "must be binary")` without a
space, producing messages like `"voteddem_allmust be binary"`.  
**Fix needed:** Change to `paste0(var, " must be binary")` in all affected lines.  
**Status:** Fixed 2026-05-29 — added space in `paste0` calls in `aprlb.R`,
`aprub.R`, and `lpr4ytz.R`. Three regression tests added to
`test-base_errors.R`; all 16 error tests now pass.

---

## [2026-05-29] RoxygenNote version in DESCRIPTION — NOT AN ISSUE

**File:** `DESCRIPTION` (line 38)  
**Note:** `RoxygenNote: 8.0.0` is correct — roxygen2 8.0.0 was released May 2026.
No action needed.
