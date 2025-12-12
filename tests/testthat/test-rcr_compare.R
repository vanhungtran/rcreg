# Tests for rcr_compare

test_that("rcr_compare returns tidy comparison table", {
  set.seed(303)
  n_subj <- 15
  n_time <- 4

  dat <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )
  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 0.6)
    idx <- dat$id == i
    dat$y[idx] <- 3 + 1.2 * dat$time[idx] + dat$x1[idx] +
      b0i + rnorm(sum(idx), 0, 0.3)
  }

  mod_int <- rcr_fit(y ~ time + x1, data = dat, id = "id", time = "time",
                     random = "intercept")
  mod_slope <- rcr_fit(y ~ time + x1, data = dat, id = "id", time = "time",
                       random = "intercept_slope")

  cmp <- rcr_compare(int = mod_int, slope = mod_slope)

  expect_s3_class(cmp, "rcr_compare")
  expect_equal(nrow(cmp), 2)
  expect_true(all(c("model", "random_type", "aic", "bic", "logLik", "df", "nobs") %in% names(cmp)))
  expect_setequal(cmp$model, c("int", "slope"))

  # Should also work when models are supplied via .models
  cmp2 <- rcr_compare(.models = list(mod_int, mod_slope))
  expect_equal(nrow(cmp2), 2)
})
