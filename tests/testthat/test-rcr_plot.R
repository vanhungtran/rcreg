# Tests for rcr_plot_predictions

test_that("rcr_plot_predictions returns a ggplot object", {
  skip_if_not_installed("ggplot2")
  set.seed(404)

  dat <- data.frame(
    id = rep(1:8, each = 3),
    time = rep(0:2, times = 8),
    x1 = rnorm(24)
  )
  dat$y <- 1 + 0.8 * dat$time + dat$x1 + rnorm(24, 0, 0.2)

  mod <- rcr_fit(y ~ time + x1, data = dat, id = "id", time = "time",
                 random = "intercept")

  p <- rcr_plot_predictions(mod)
  expect_true(inherits(p, "ggplot"))
})
