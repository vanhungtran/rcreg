<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcreg: Random Coefficient Regression Models for Repeated Measurements

<!-- badges: start -->
<!-- badges: end -->

## Overview

`rcreg` provides a high-level interface for fitting **random coefficient regression models** (random intercept and random slope linear mixed models) for repeated measurement data. The package simplifies the specification of longitudinal mixed models by wrapping the powerful `lme4` package, offering convenient functions for:

- Model fitting with intuitive syntax
- Clean summaries of fixed and random effects
- Subject-specific and population-averaged predictions
- Model diagnostics and visualizations

## Background

Random coefficient regression models are a class of linear mixed models particularly well-suited for analyzing repeated measures or longitudinal data. These models account for **between-subject heterogeneity** by allowing each subject to have their own intercept and/or slope parameters.

### The Model

For subject *i* = 1, ..., *N*, measurement *j* = 1, ..., *n*ᵢ:

y*ᵢⱼ* = β₀ + β₁t*ᵢⱼ* + **x**'*ᵢⱼ***β** + b₀*ᵢ* + b₁*ᵢ*t*ᵢⱼ* + ε*ᵢⱼ*

where:
- (b₀*ᵢ*, b₁*ᵢ*)' ~ N(0, **D**) are subject-specific random effects
- ε*ᵢⱼ* ~ N(0, σ²) are residual errors
- All random effects and residuals are independent

The model allows for:
- **Random intercepts** (b₀*ᵢ*): Subject-specific baseline levels
- **Random slopes** (b₁*ᵢ*): Subject-specific rates of change over time
- **Correlation** between random intercepts and slopes

## Installation

You can install the development version of `rcreg` from GitHub:

```r
# install.packages("devtools")
devtools::install_github("yourusername/rcreg")
```

## Quick Start

```r
library(rcreg)

# Load example data
data(sim_rcr)
head(sim_rcr)
#>   id time        x1        y
#> 1  1    0 -0.560476 11.09348
#> 2  1    1 -0.560476 14.42718
#> 3  1    2 -0.560476 16.26532
#> 4  1    3 -0.560476 16.93117
#> 5  1    4 -0.560476 20.85978
#> 6  2    0 -0.230177 11.56178

# Fit a random intercept and slope model
mod <- rcr_fit(
  formula = y ~ time + x1,
  data = sim_rcr,
  id = "id",
  time = "time",
  random = "intercept_slope"
)

# View summary
summary_mod <- rcr_summary(mod)
print(summary_mod)

# Make predictions
# Subject-specific predictions (including random effects)
pred_subj <- rcr_predict(mod, type = "subject")

# Population-averaged predictions (fixed effects only)
pred_pop <- rcr_predict(mod, type = "population")

# Diagnostic plots
rcr_diagnostics(mod)
```

## Example: Complete Workflow

Here's a complete example demonstrating the main features of `rcreg`:

```r
library(rcreg)
data(sim_rcr)

# 1. Explore the data structure
str(sim_rcr)
#> 'data.frame':    500 obs. of  4 variables:
#>  $ id  : int  1 1 1 1 1 2 2 2 2 2 ...
#>  $ time: num  0 1 2 3 4 0 1 2 3 4 ...
#>  $ x1  : num  -0.56 -0.56 -0.56 -0.56 -0.56 ...
#>  $ y   : num  11.1 14.4 16.3 16.9 20.9 ...

# 2. Fit different model specifications

# Random intercept only
mod_int <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
                   random = "intercept")

# Random slope only
mod_slope <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
                     random = "slope")

# Random intercept and slope
mod_both <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
                    random = "intercept_slope")

# 3. Compare models using summaries
summary_int <- rcr_summary(mod_int)
summary_both <- rcr_summary(mod_both)

# Compare AIC/BIC
cat("Random Intercept Model - AIC:", summary_int$aic, "BIC:", summary_int$bic, "\n")
cat("Random Int+Slope Model - AIC:", summary_both$aic, "BIC:", summary_both$bic, "\n")

# 4. Examine variance components and ICC
rcr_icc(mod_int)   # Simple ICC for random intercept model
rcr_icc(mod_both)  # ICC components for intercept+slope model

# 5. Extract random effects
random_effects <- rcr_ranef(mod_both)
head(random_effects)

# 6. Make predictions for new data
newdata <- data.frame(
  id = rep(1:3, each = 6),
  time = rep(0:5, times = 3),
  x1 = rep(c(-1, 0, 1), each = 6)
)

# Predictions with standard errors (population level)
pred_new <- rcr_predict(mod_both, newdata = newdata,
                        type = "population", se.fit = TRUE)
head(pred_new$fit)
head(pred_new$se.fit)

# 7. Run diagnostics
rcr_diagnostics(mod_both, which = c(1, 2, 4))

# 8. Center time variable (optional preprocessing)
sim_rcr_centered <- rcr_center_time(sim_rcr, time = "time")
head(sim_rcr_centered)
```

## Key Functions

### Model Fitting
- `rcr_fit()`: Fit random coefficient regression models with flexible random effects structures

### Summaries and Inference
- `rcr_summary()`: Comprehensive summary of fixed effects, random effects, and model fit
- `rcr_icc()`: Compute intraclass correlation coefficient(s)
- `rcr_ranef()`: Extract random effects (BLUPs)

### Prediction
- `rcr_predict()`: Make subject-specific or population-averaged predictions
- `fitted()`, `residuals()`: Extract fitted values and residuals

### Diagnostics
- `rcr_diagnostics()`: Diagnostic plots for model checking
- `plot()`: Convenience method for diagnostics

### Utilities
- `rcr_center_time()`: Center time variables (global or within-subject)

## Data Structure

`rcreg` expects data in **long format** (one row per observation):

| id | time | x1 | y |
|----|------|-------|------|
| 1  | 0    | 0.5   | 10.2 |
| 1  | 1    | 0.5   | 12.1 |
| 1  | 2    | 0.5   | 14.3 |
| 2  | 0    | -0.3  | 9.8  |
| 2  | 1    | -0.3  | 11.5 |

Where:
- `id`: Subject/cluster identifier
- `time`: Time or sequence variable
- `x1, x2, ...`: Covariates (time-varying or time-invariant)
- `y`: Response variable

## Model Assumptions

Random coefficient regression models assume:

1. **Linearity**: The relationship between predictors and response is linear
2. **Independence**: Observations from different subjects are independent
3. **Normality**: Random effects and residuals are normally distributed
4. **Homoscedasticity**: Constant residual variance
5. **Correct specification**: The model structure appropriately captures the data-generating process

Use `rcr_diagnostics()` to check these assumptions visually.

## Comparison with Base `lme4`

While `rcreg` uses `lme4` under the hood, it offers several advantages:

| Feature | `lme4` | `rcreg` |
|---------|--------|---------|
| Syntax for random effects | Manual formula construction | Simple string argument |
| Longitudinal focus | General-purpose | Optimized for repeated measures |
| ICC calculation | Manual | Built-in `rcr_icc()` |
| Clean summaries | Requires parsing | Formatted with `rcr_summary()` |
| Diagnostic plots | Manual creation | Built-in `rcr_diagnostics()` |
| Time centering | Manual preprocessing | Built-in `rcr_center_time()` |

## Citation

If you use `rcreg` in your research, please cite:

```
Your Name (2024). rcreg: Random Coefficient Regression Models for Repeated Measurements.
R package version 0.1.0. https://github.com/yourusername/rcreg
```

## Getting Help

- For bug reports and feature requests: [GitHub Issues](https://github.com/yourusername/rcreg/issues)
- For questions about usage: Open a discussion on GitHub

## References

- Fitzmaurice, G. M., Laird, N. M., & Ware, J. H. (2011). *Applied Longitudinal Analysis* (2nd ed.). Wiley.
- Verbeke, G., & Molenberghs, G. (2000). *Linear Mixed Models for Longitudinal Data*. Springer.
- Bates, D., Mächler, M., Bolker, B., & Walker, S. (2015). Fitting Linear Mixed-Effects Models Using lme4. *Journal of Statistical Software*, 67(1), 1-48.

## License

MIT License - see [LICENSE](LICENSE) file for details.
