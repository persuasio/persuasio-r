## R CMD check results

0 errors | 0 warnings | 1 note

* This is a second revised submission of a new package.
* In response to the CRAN manual documentation request, added `\value`
  documentation for all exported S3 print methods:
  `print.aprlb()`, `print.aprub()`, `print.calc4persuasio()`,
  `print.lpr4ytz()`, `print.persuasio4ytz()`,
  `print.persuasio4ytz2lpr()`, and `print.persuasio4yz()`.
  These now document that the methods invisibly return `x` and are called for
  their side effect of printing formatted summaries.

* In the first revision, in response to the CRAN incoming pre-test note, the
  examples for `persuasio4ytz()` and `persuasio4ytz2lpr()` were shortened by
  reducing the bootstrap replications shown in the examples from `nboot = 1000`
  to `nboot = 100`. The function defaults and package behavior were not changed.

Checks were run on:

* macOS Tahoe 26.5.1 (aarch64-apple-darwin20) using R 4.5.2
* Windows Server 2022 x64 (x86_64-w64-mingw32), using R Under development
  (unstable) (2026-07-26 r90304 ucrt)

No errors or warnings were reported. The only note was the expected CRAN
incoming feasibility note for a new submission.
