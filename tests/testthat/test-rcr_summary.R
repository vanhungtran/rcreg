# Tests for rcr_summary function

test_that("rcr_summary returns correct structure", {
  # Generate simple test data
  set.seed(111)
  n_subj <- 20
  n_time <- 4

  test_data <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 1)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b0i + rnorm(sum(idx), 0, 0.5)
  }

  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "intercept")

  summ <- rcr_summary(mod)

  # Check class
  expect_s3_class(summ, "rcr_summary")

  # Check that all expected components exist
  expect_true("fixed_effects" %in% names(summ))
  expect_true("random_effects" %in% names(summ))
  expect_true("residual_variance" %in% names(summ))
  expect_true("icc" %in% names(summ))
  expect_true("aic" %in% names(summ))
  expect_true("bic" %in% names(summ))
  expect_true("nobs" %in% names(summ))
  expect_true("ngrps" %in% names(summ))

  # Check data types
  expect_true(is.data.frame(summ$fixed_effects))
  expect_true(is.data.frame(summ$random_effects))
  expect_true(is.numeric(summ$residual_variance))
  expect_true(is.numeric(summ$aic))
  expect_true(is.numeric(summ$bic))
})


test_that("rcr_summary throws error for non-rcr_mod object", {
  expect_error(
    rcr_summary(lm(mpg ~ wt, data = mtcars)),
    "Object must be of class 'rcr_mod'"
  )
})


test_that("print method works for rcr_summary", {
  set.seed(222)
  test_data <- data.frame(
    id = rep(1:10, each = 3),
    time = rep(0:2, times = 10),
    x1 = rnorm(30)
  )

  for (i in 1:10) {
    b0i <- rnorm(1, 0, 1)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b0i + rnorm(sum(idx), 0, 0.5)
  }

  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "intercept")
  summ <- rcr_summary(mod)

  # Test that print method runs without error
  expect_output(print(summ), "Random Coefficient Regression Model Summary")
  expect_output(print(summ), "Fixed Effects")
  expect_output(print(summ), "Random Effects Variance Components")
  expect_output(print(summ), "Intraclass Correlation Coefficient")
})
