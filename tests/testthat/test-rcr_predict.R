# Tests for rcr_predict enhancements

test_that("rcr_predict supports intervals for population predictions", {
  set.seed(101)
  n_subj <- 12
  n_time <- 3

  dat <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 0.5)
    idx <- dat$id == i
    dat$y[idx] <- 4 + 1.5 * dat$time[idx] + dat$x1[idx] + b0i + rnorm(sum(idx), 0, 0.3)
  }

  mod <- rcr_fit(y ~ time + x1, data = dat, id = "id", time = "time",
                 random = "intercept")

  preds_ci <- rcr_predict(mod, type = "population", se.fit = TRUE,
                          interval = "confidence", level = 0.90)

  expect_s3_class(preds_ci, "data.frame")
  expect_true(all(c("fit", "se.fit", "lwr", "upr") %in% names(preds_ci)))
  expect_equal(nrow(preds_ci), nrow(dat))

  preds_pi <- rcr_predict(mod, type = "population", interval = "prediction")
  expect_true(all(c("fit", "lwr", "upr") %in% names(preds_pi)))
  expect_equal(nrow(preds_pi), nrow(dat))
  expect_true(all(preds_pi$upr > preds_pi$lwr))
})


test_that("rcr_predict validates inputs for intervals and newdata", {
  set.seed(202)
  dat <- data.frame(
    id = rep(1:6, each = 3),
    time = rep(0:2, times = 6),
    x1 = rnorm(18)
  )
  dat$y <- 2 + dat$time + dat$x1 + rnorm(18, 0, 0.4)

  mod <- rcr_fit(y ~ time + x1, data = dat, id = "id", time = "time",
                 random = "intercept")

  expect_error(
    rcr_predict(mod, type = "subject", interval = "confidence"),
    "Intervals are only available"
  )

  bad_newdata <- data.frame(time = 0:2, x1 = rnorm(3))
  expect_error(
    rcr_predict(mod, newdata = bad_newdata, type = "subject"),
    "must contain columns"
  )

  bad_time <- data.frame(id = 1:3, x1 = rnorm(3))
  expect_error(
    rcr_predict(mod, newdata = bad_time, type = "population"),
    "must contain the time variable"
  )
})
