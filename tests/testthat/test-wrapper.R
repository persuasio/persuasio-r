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
