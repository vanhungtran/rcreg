# rcreg 0.1.0

## Initial Release

* Added `rcr_fit()` for fitting random coefficient regression models with flexible random effects structures (intercept, slope, or both)
* Added `rcr_summary()` for clean summaries of fitted models including fixed effects, random effects, and model fit statistics
* Added `rcr_predict()` for making subject-specific or population-averaged predictions
* Added `rcr_diagnostics()` for model diagnostic plots
* Added helper functions:
  * `rcr_icc()` for computing intraclass correlation coefficients
  * `rcr_center_time()` for centering time variables
  * `rcr_ranef()` for extracting random effects
* Included simulated dataset `sim_rcr` for examples and testing
* S3 methods for `print()`, `plot()`, `fitted()`, `residuals()`, `coef()`, and `vcov()`
* Comprehensive documentation with examples
* Unit tests using testthat
