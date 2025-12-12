# Tests for rcr_fit function

test_that("rcr_fit works with random intercept model", {
  # Generate simple test data
  set.seed(456)
  n_subj <- 20
  n_time <- 4

  test_data <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  # Add random intercept and response
  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 1)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b0i + rnorm(sum(idx), 0, 0.5)
  }

  # Fit model
  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "intercept")

  # Tests
  expect_s3_class(mod, "rcr_mod")
  expect_true("fit" %in% names(mod))
  expect_equal(mod$random_type, "intercept")
  expect_equal(mod$id, "id")
  expect_equal(mod$time, "time")

  # Check that the model fit is a lmerMod object
  expect_s4_class(mod$fit, "lmerMod")

  # Check that variance components are positive
  vc <- lme4::VarCorr(mod$fit)
  vc_df <- as.data.frame(vc)
  expect_true(all(vc_df$vcov > 0))
})


test_that("rcr_fit works with random intercept and slope model", {
  # Generate simple test data
  set.seed(789)
  n_subj <- 20
  n_time <- 4

  test_data <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  # Add random intercept, random slope, and response
  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 1)
    b1i <- rnorm(1, 0, 0.5)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b0i + b1i * test_data$time[idx] + rnorm(sum(idx), 0, 0.5)
  }

  # Fit model
  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "intercept_slope")

  # Tests
  expect_s3_class(mod, "rcr_mod")
  expect_equal(mod$random_type, "intercept_slope")
  expect_s4_class(mod$fit, "lmerMod")

  # Check that variance components are positive
  vc <- lme4::VarCorr(mod$fit)
  vc_df <- as.data.frame(vc)
  expect_true(all(vc_df$vcov > 0))
})


test_that("rcr_fit works with random slope only model", {
  # Generate simple test data
  set.seed(321)
  n_subj <- 20
  n_time <- 4

  test_data <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  # Add random slope and response
  for (i in 1:n_subj) {
    b1i <- rnorm(1, 0, 0.5)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b1i * test_data$time[idx] + rnorm(sum(idx), 0, 0.5)
  }

  # Fit model
  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "slope")

  # Tests
  expect_s3_class(mod, "rcr_mod")
  expect_equal(mod$random_type, "slope")
  expect_s4_class(mod$fit, "lmerMod")
})


test_that("rcr_fit throws error for missing variables", {
  test_data <- data.frame(
    id = rep(1:10, each = 3),
    time = rep(0:2, times = 10),
    y = rnorm(30)
  )

  # Test missing ID variable
  expect_error(
    rcr_fit(y ~ time, data = test_data, id = "subject", time = "time"),
    "ID variable 'subject' not found in data"
  )

  # Test missing time variable
  expect_error(
    rcr_fit(y ~ time, data = test_data, id = "id", time = "timepoint"),
    "Time variable 'timepoint' not found in data"
  )
})


test_that("rcr_fit validates random argument", {
  test_data <- data.frame(
    id = rep(1:10, each = 3),
    time = rep(0:2, times = 10),
    x1 = rnorm(30),
    y = rnorm(30)
  )

  # Test invalid random argument
  expect_error(
    rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
            random = "invalid"),
    "'arg' should be one of"
  )
})


test_that("print method works for rcr_mod", {
  set.seed(999)
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

  # Test that print method runs without error
  expect_output(print(mod), "Random Coefficient Regression Model")
  expect_output(print(mod), "Random effects structure")
})
