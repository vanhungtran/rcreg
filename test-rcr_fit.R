test_that("rcr_fit works with different random structures", {
  # Assuming sim_rcr is available in the package environment or loaded
  # If running devtools::test(), data should be available
  
  # Intercept only
  mod1 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time", 
                  random = "intercept")
  expect_s3_class(mod1, "rcr_mod")
  expect_equal(mod1$random_type, "intercept")
  
  # Slope only
  mod2 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time", 
                  random = "slope")
  expect_s3_class(mod2, "rcr_mod")
  
  # Both
  mod3 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time", 
                  random = "intercept_slope")
  expect_s3_class(mod3, "rcr_mod")
})

test_that("rcr_fit validates inputs", {
  expect_error(rcr_fit(y ~ time, data = sim_rcr, id = "wrong_id", time = "time"))
})