# shared toy dataset
df <- data.frame(
  y = c(1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  t = c(1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0),
  z = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
  x1 = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
)

test_that("aprlb rejects non-binary inputs", {
  df_bad <- df
  df_bad$y[1] <- 2
  expect_error(aprlb(y = "y", z = "z", data = df_bad), "must be binary")
  df_bad2 <- df
  df_bad2$z[2] <- -1
  expect_error(aprlb(y = "y", z = "z", data = df_bad2), "must be binary")
})

test_that("aprub rejects non-binary treatment", {
  df_bad <- df
  df_bad$t[1] <- 3
  expect_error(aprub(y = "y", t = "t", z = "z", data = df_bad), "must be binary")
})

test_that("lpr4ytz rejects invalid binary variables", {
  df_bad <- df
  df_bad$z[1] <- 9
  expect_error(lpr4ytz(y = "y", t = "t", z = "z", data = df_bad), "must be binary")
})

test_that("calc4persuasio enforces [0,1] bounds", {
  expect_error(calc4persuasio(y1 = 1.2, y0 = 0.3), "must be in \\[0,1\\]")
  expect_error(calc4persuasio(y1 = 0.5, y0 = -0.1), "must be in \\[0,1\\]")
})

test_that("aprlb error message has space before 'must be binary'", {
  df_bad <- df
  df_bad$y[1] <- 2
  expect_error(aprlb(y = "y", z = "z", data = df_bad), "y must be binary")
  df_bad2 <- df
  df_bad2$z[1] <- 2
  expect_error(aprlb(y = "y", z = "z", data = df_bad2), "z must be binary")
})

test_that("aprub error message has space before 'must be binary'", {
  df_bad <- df
  df_bad$t[1] <- 3
  expect_error(aprub(y = "y", t = "t", z = "z", data = df_bad), "t must be binary")
})

test_that("lpr4ytz error message has space before 'must be binary'", {
  df_bad <- df
  df_bad$z[1] <- 9
  expect_error(lpr4ytz(y = "y", t = "t", z = "z", data = df_bad), "z must be binary")
})

test_that("aprlb handles invalid model argument", {
  expect_error(
    aprlb(y = "y", z = "z", model = "not_a_model", data = df),
    "should be one of"
  )
})

test_that("aprub handles invalid model argument", {
  expect_error(
    aprub(y = "y", t = "t", z = "z", model = "not_a_model", data = df),
    "should be one of"
  )
})

test_that("lpr4ytz handles invalid model argument", {
  expect_error(
    lpr4ytz(y = "y", t = "t", z = "z", model = "not_a_model", data = df),
    "should be one of"
  )
})

test_that("wrapper estimators reject invalid inference methods", {
  expect_error(
    persuasio4ytz(y = "y", t = "t", z = "z", method = "not_a_method", data = df),
    "should be one of"
  )
  expect_error(
    persuasio4ytz2lpr(y = "y", t = "t", z = "z", method = "not_a_method", data = df),
    "should be one of"
  )
  expect_error(
    persuasio4yz(y = "y", z = "z", method = "not_a_method", data = df),
    "should be one of"
  )
})
