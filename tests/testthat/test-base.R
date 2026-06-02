# shared toy dataset
df <- data.frame(
  y = c(1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  t = c(1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  z = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
  x1 = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
)


test_that("aprlb works with required inputs only", {
  res <- aprlb(y = "y", z = "z", data = df)
  expect_s3_class(res, "aprlb")
  expect_true(is.numeric(res$lb_coef))
  expect_true(res$lb_coef >= 0 && res$lb_coef <= 1)
  expect_true(!is.null(res$outcome))
  expect_true(!is.null(res$instrument))
})

test_that("aprub works with required inputs only", {
  res <- aprub(y = "y", t = "t", z = "z", data = df)
  expect_s3_class(res, "aprub")
  expect_true(is.numeric(res$ub_coef))
  expect_true(res$ub_coef >= 0 && res$ub_coef <= 1)
  expect_true(!is.null(res$outcome))
  expect_true(!is.null(res$treatment))
  expect_true(!is.null(res$instrument))
})

test_that("lpr4ytz works with required inputs only", {
  res <- lpr4ytz(y = "y", t = "t", z = "z", data = df)
  expect_s3_class(res, "lpr4ytz")
  expect_true(is.numeric(res$lpr))
  expect_true(res$lpr >= 0 && res$lpr <= 1)
  expect_true(!is.null(res$outcome))
  expect_true(!is.null(res$treatment))
  expect_true(!is.null(res$instrument))
})

test_that("calc4persuasio works independently of data", {
  res <- calc4persuasio(y1 = 0.6, y0 = 0.3, e1 = 0.7, e0 = 0.2)
  expect_s3_class(res, "calc4persuasio")
  expect_named(res, c("apr", "lpr", "inputs", "case"))
  expect_length(res$apr, 2)
  expect_length(res$lpr, 2)
  expect_true(res$apr["lower"] <= res$apr["upper"])
  expect_true(res$lpr["lower"] <= res$lpr["upper"])
  expect_true(all(is.finite(unlist(res[c("apr", "lpr")]))))
})
