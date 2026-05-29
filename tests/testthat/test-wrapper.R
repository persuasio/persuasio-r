# toy dataset
df <- data.frame(
  y = c(1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  t = c(1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  z = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
  x1 = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
)

test_that("persuasio4ytz returns structured result", {

  res <- persuasio4ytz(df, "y", "t", "z")

  expect_true(is.list(res))
  expect_true("lb_coef" %in% names(res))
  expect_true("ub_coef" %in% names(res) || is.null(res$ub_coef))
})


test_that("persuasio4yz returns scalar bound", {

  res <- persuasio4yz(df, "y", "z")

  expect_true(is.numeric(res$lb_coef))
  expect_true(res$lb_coef >= 0 && res$lb_coef <= 1)
})


test_that("persuasio4ytz2lpr returns lpr estimate", {

  res <- persuasio4ytz2lpr(df, "y", "t", "z")

  expect_true(is.numeric(res$lpr))
  expect_true(res$lpr >= 0 && res$lpr <= 1)
})

test_that("persuasio wrapper routes to apr correctly", {

  res <- persuasio(
    est = "apr",
    varlist = c("y","t","z"),
    data = df
  )

  expect_true(!is.null(res))
  expect_true(is.list(res))
  expect_true(!is.null(res$lb_coef))
})

# Reproducibility tests for persuasio4ytz bootstrap
# Both tests fail with the current code:
#   test 1 fails because set.seed(NULL) inside the function overrides
#           any external seed, so two runs with the same prior set.seed()
#           produce different CI values.
#   test 2 fails because the seed parameter does not exist yet,
#           causing an "unused argument" error caught by expect_no_error.

test_that("persuasio4ytz bootstrap respects external RNG state", {

  set.seed(42)
  res1 <- persuasio4ytz(df, "y", "t", "z", method = "bootstrap", nboot = 200)

  set.seed(42)
  res2 <- persuasio4ytz(df, "y", "t", "z", method = "bootstrap", nboot = 200)

  expect_equal(res1$ci_lb, res2$ci_lb)
  expect_equal(res1$ci_ub, res2$ci_ub)
})

test_that("persuasio4ytz accepts seed parameter", {

  expect_no_error(
    persuasio4ytz(df, "y", "t", "z", method = "bootstrap", nboot = 50, seed = 42)
  )
})

test_that("persuasio wrapper routes to yz with y, z, x order", {

  res <- persuasio(
    est = "yz",
    varlist = c("y", "z", "x1"),
    data = df,
    method = "bootstrap",
    nboot = 5
  )

  expect_s3_class(res, "persuasio4yz")
  expect_equal(res$outcome, "y")
  expect_equal(res$instrument, "z")
  expect_equal(res$covariates, "x1")
})
