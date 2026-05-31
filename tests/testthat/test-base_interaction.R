test_that("interaction model works", {

  df <- data.frame(
    y = c(1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
    t = c(1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0),
    z = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
    x1 = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
  )

    res1 <- aprlb(y = "y", z = "z", x = "x1", model = "interaction", data = df)
    expect_true(is.numeric(res1$lb_coef))
    res2 <- aprub(y = "y", t = "t", z = "z", x = "x1", model = "interaction", data = df)
    expect_true(is.numeric(res2$ub_coef))
    res3 <- lpr4ytz(y = "y", t = "t", z = "z", x = "x1", model = "interaction", data = df)
    expect_true(is.numeric(res3$lpr))

})

test_that("interaction model warns on collinear covariates", {
  df_collinear <- data.frame(
    y  = c(1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
    t  = c(1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0),
    z  = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
    x1 = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0)  # perfectly predicts z
  )
  expect_warning(
    aprlb(y = "y", z = "z", x = "x1", model = "interaction", data = df_collinear)
  )
})
