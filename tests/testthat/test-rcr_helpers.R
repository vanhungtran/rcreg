# Tests for helper functions

test_that("rcr_icc works for random intercept model", {
  set.seed(333)
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

  icc <- rcr_icc(mod)

  # Check that ICC is numeric and between 0 and 1
  expect_true(is.numeric(icc))
  expect_true(icc >= 0 && icc <= 1)
})


test_that("rcr_icc works for random intercept and slope model", {
  set.seed(444)
  n_subj <- 20
  n_time <- 4

  test_data <- data.frame(
    id = rep(1:n_subj, each = n_time),
    time = rep(0:(n_time - 1), times = n_subj),
    x1 = rnorm(n_subj * n_time)
  )

  for (i in 1:n_subj) {
    b0i <- rnorm(1, 0, 1)
    b1i <- rnorm(1, 0, 0.5)
    idx <- test_data$id == i
    test_data$y[idx] <- 5 + 2 * test_data$time[idx] + test_data$x1[idx] +
      b0i + b1i * test_data$time[idx] + rnorm(sum(idx), 0, 0.5)
  }

  mod <- rcr_fit(y ~ time + x1, data = test_data, id = "id", time = "time",
                 random = "intercept_slope")

  icc <- rcr_icc(mod)

  # Check that ICC is a list with expected components
  expect_true(is.list(icc))
  expect_true("intercept" %in% names(icc))
  expect_true("slope_var" %in% names(icc))

  # Check that values are numeric and in reasonable ranges
  expect_true(is.numeric(icc$intercept))
  expect_true(icc$intercept >= 0 && icc$intercept <= 1)
  expect_true(is.numeric(icc$slope_var))
  expect_true(icc$slope_var >= 0)
})


test_that("rcr_center_time works with global centering", {
  test_data <- data.frame(
    id = rep(1:5, each = 4),
    time = rep(0:3, times = 5),
    y = rnorm(20)
  )

  data_centered <- rcr_center_time(test_data, time = "time")

  # Check that new column exists
  expect_true("time_centered" %in% names(data_centered))

  # Check that centering is correct
  expect_equal(mean(data_centered$time_centered), 0, tolerance = 1e-10)
})


test_that("rcr_center_time works with within-subject centering", {
  test_data <- data.frame(
    id = rep(1:5, each = 4),
    time = rep(0:3, times = 5),
    y = rnorm(20)
  )

  data_centered <- rcr_center_time(test_data, time = "time", id = "id")

  # Check that new column exists
  expect_true("time_centered" %in% names(data_centered))

  # Check that within-subject means are zero
  subj_means <- tapply(data_centered$time_centered, data_centered$id, mean)
  expect_true(all(abs(subj_means) < 1e-10))
})


test_that("rcr_center_time works with scaling", {
  test_data <- data.frame(
    id = rep(1:5, each = 4),
    time = rep(0:3, times = 5),
    y = rnorm(20)
  )

  data_centered <- rcr_center_time(test_data, time = "time", scale = TRUE)

  # Check that new column exists
  expect_true("time_centered" %in% names(data_centered))

  # Check that mean is zero
  expect_equal(mean(data_centered$time_centered), 0, tolerance = 1e-10)
})


test_that("rcr_center_time throws error for missing variables", {
  test_data <- data.frame(
    id = rep(1:5, each = 4),
    time = rep(0:3, times = 5),
    y = rnorm(20)
  )

  expect_error(
    rcr_center_time(test_data, time = "timepoint"),
    "Time variable 'timepoint' not found in data"
  )

  expect_error(
    rcr_center_time(test_data, time = "time", id = "subject"),
    "ID variable 'subject' not found in data"
  )
})


test_that("rcr_ranef extracts random effects", {
  set.seed(555)
  n_subj <- 10
  n_time <- 3

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

  re <- rcr_ranef(mod)

  # Check that random effects are returned
  expect_true(is.list(re))
  expect_equal(length(re), 1)  # One grouping factor
  expect_equal(nrow(re[[1]]), n_subj)  # One row per subject
})
