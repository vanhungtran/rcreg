# rcreg Package Summary

## Package Overview

**Package Name:** `rcreg` (Random Coefficient Regression)
**Version:** 0.1.0
**Purpose:** High-level interface for fitting random coefficient regression models (random intercept and random slope linear mixed models) for repeated measurement data.

## Package Structure

```
rcreg/
├── DESCRIPTION              # Package metadata and dependencies
├── NAMESPACE                # Exported functions and imports
├── LICENSE                  # MIT License
├── README.Rmd              # Main package documentation
├── NEWS.md                 # Version history and changes
├── INSTALLATION.md         # Installation and setup guide
├── .Rbuildignore           # Files to ignore during build
├── .gitignore              # Git ignore patterns
│
├── R/                      # R source code
│   ├── rcr_fit.R           # Main model fitting function
│   ├── rcr_summary.R       # Model summary functions
│   ├── rcr_predict.R       # Prediction methods
│   ├── rcr_diagnostics.R   # Diagnostic plots
│   ├── rcr_helpers.R       # Helper functions (ICC, centering, etc.)
│   ├── data.R              # Data documentation
│   └── rcreg-package.R     # Package-level documentation
│
├── data/                   # Package datasets
│   └── sim_rcr.rda         # Simulated repeated measures data
│
├── data-raw/               # Scripts to generate datasets
│   ├── generate_sim_rcr.R  # Data generation (usethis approach)
│   └── create_data.R       # Data generation (standalone)
│
├── tests/                  # Unit tests
│   ├── testthat.R          # Test configuration
│   └── testthat/
│       ├── test-rcr_fit.R      # Tests for model fitting
│       ├── test-rcr_summary.R  # Tests for summaries
│       └── test-rcr_helpers.R  # Tests for helper functions
│
└── vignettes/              # Long-form documentation
    └── rcreg-quickstart.Rmd # Quick start guide
```

## Core Functions

### 1. Model Fitting

#### `rcr_fit(formula, data, id, time, random, REML = TRUE, ...)`

Fits random coefficient regression models with three random effects specifications:
- `random = "intercept"`: Random intercept only
- `random = "slope"`: Random slope only
- `random = "intercept_slope"`: Both random intercept and slope with correlation

**Returns:** An S3 object of class `rcr_mod` containing:
- `fit`: The fitted `lmerMod` object from `lme4`
- `formula`, `random_formula`, `id`, `time`, `random_type`: Model specifications
- `data`: Original data
- `call`: The function call

**Example:**
```r
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")
```

### 2. Model Summary

#### `rcr_summary(object, ...)`

Provides comprehensive summary of fitted models including:
- Fixed effects estimates with standard errors, t-values, and confidence intervals
- Random effects variance/covariance components
- Intraclass correlation coefficient(s)
- Model fit statistics (AIC, BIC, log-likelihood)
- Sample size information

**Returns:** An S3 object of class `rcr_summary`

**Example:**
```r
summ <- rcr_summary(mod)
print(summ)
```

### 3. Prediction

#### `rcr_predict(object, newdata = NULL, type, se.fit = FALSE, ...)`

Makes predictions at two levels:
- `type = "subject"`: Subject-specific predictions including random effects (BLUPs)
- `type = "population"`: Population-averaged predictions (fixed effects only)

Optional standard errors for population-level predictions.

**Example:**
```r
# Subject-specific predictions
pred_subj <- rcr_predict(mod, type = "subject")

# Population predictions with SEs
pred_pop <- rcr_predict(mod, type = "population", se.fit = TRUE)
```

### 4. Diagnostics

#### `rcr_diagnostics(object, which = c(1, 2, 4), ask = NULL, ...)`

Produces diagnostic plots:
1. Residuals vs Fitted values (linearity, homoscedasticity)
2. QQ-plot of residuals (normality)
3. Scale-Location plot (homoscedasticity)
4. QQ-plot of random effects (normality of random effects)

**Example:**
```r
rcr_diagnostics(mod)
plot(mod)  # Convenience method
```

### 5. Helper Functions

#### `rcr_icc(object)`

Computes intraclass correlation coefficient(s):
- For random intercept models: Single ICC value
- For intercept+slope models: List with intercept ICC, slope variance, and covariance

**Example:**
```r
icc <- rcr_icc(mod)
```

#### `rcr_center_time(data, time, id = NULL, scale = FALSE)`

Centers time variable:
- Global centering (if `id = NULL`)
- Within-subject centering (if `id` specified)
- Optional scaling by standard deviation

**Example:**
```r
data_c <- rcr_center_time(sim_rcr, time = "time")
```

#### `rcr_ranef(object, ...)`

Extracts random effects (BLUPs) for each subject.

**Example:**
```r
re <- rcr_ranef(mod)
```

### 6. S3 Methods

- `print.rcr_mod()`: Print method for fitted models
- `print.rcr_summary()`: Print method for summaries
- `plot.rcr_mod()`: Plot method (calls `rcr_diagnostics()`)
- `fitted.rcr_mod()`: Extract fitted values
- `residuals.rcr_mod()`: Extract residuals
- `coef.rcr_mod()`: Extract fixed effects coefficients
- `vcov.rcr_mod()`: Extract variance-covariance matrix of fixed effects

## Statistical Model

For subject *i* = 1, ..., *N*, measurement *j* = 1, ..., *n*ᵢ:

**y**ᵢⱼ = β₀ + β₁**t**ᵢⱼ + **x**'ᵢⱼ**β** + *b*₀ᵢ + *b*₁ᵢ**t**ᵢⱼ + εᵢⱼ

where:
- (*b*₀ᵢ, *b*₁ᵢ)' ~ N(0, **D**) are subject-specific random effects
- εᵢⱼ ~ N(0, σ²) are residual errors
- All random effects and residuals are independent

### Variance-Covariance Matrix **D**

**D** = [ σ²_b₀      σ_b₀,b₁ ]
        [ σ_b₀,b₁    σ²_b₁   ]

Where:
- σ²_b₀: Variance of random intercepts
- σ²_b₁: Variance of random slopes
- σ_b₀,b₁: Covariance between random intercepts and slopes

## Example Dataset: `sim_rcr`

Simulated longitudinal data with:
- 100 subjects
- 5 time points per subject (time = 0, 1, 2, 3, 4)
- 500 total observations

**Variables:**
- `id`: Subject identifier (1-100)
- `time`: Time of measurement (0-4)
- `x1`: Time-invariant covariate ~ N(0,1)
- `y`: Response variable

**Data Generation Parameters:**
- Fixed effects: β₀ = 10, β₁ = 2, β_x₁ = 1.5
- Random intercept variance: σ²_b₀ = 4
- Random slope variance: σ²_b₁ = 1
- Covariance: σ_b₀,b₁ = 0.5
- Residual variance: σ² = 4

## Dependencies

### Required (Imports):
- `lme4` (>= 1.1-0): Core mixed model engine
- `stats`: Statistical functions
- `methods`: S3/S4 methods
- `graphics`: Plotting functions

### Suggested:
- `ggplot2`: Enhanced plotting
- `nlme`: Alternative mixed model package
- `broom.mixed`: Tidy summaries
- `testthat` (>= 3.0.0): Unit testing
- `knitr`: Vignette building
- `rmarkdown`: Documentation

## Testing

The package includes comprehensive unit tests using `testthat`:

- **test-rcr_fit.R**: Tests for model fitting with all three random effects structures, error handling, and print methods
- **test-rcr_summary.R**: Tests for summary generation and output structure
- **test-rcr_helpers.R**: Tests for ICC calculation, time centering, and random effects extraction

To run tests:
```r
devtools::test()
```

## Installation

### From GitHub:
```r
devtools::install_github("yourusername/rcreg")
```

### From local source:
```r
devtools::install("rcreg")
```

## Building the Package

```r
# Generate documentation
devtools::document()

# Run tests
devtools::test()

# Check package
devtools::check()

# Build package
devtools::build()
```

## Usage Example

```r
library(rcreg)

# Load data
data(sim_rcr)

# Fit model
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")

# Summary
rcr_summary(mod)

# ICC
rcr_icc(mod)

# Predictions
pred <- rcr_predict(mod, type = "subject")

# Diagnostics
rcr_diagnostics(mod)
```

## Key Features

1. **Simplified Syntax**: Easy specification of random effects without complex formula construction
2. **Longitudinal Focus**: Optimized for repeated measures data
3. **Clean Output**: Well-formatted summaries and diagnostic plots
4. **Comprehensive**: Full workflow from data preprocessing to model diagnostics
5. **Well-Tested**: Extensive unit tests ensuring reliability
6. **Well-Documented**: Detailed roxygen2 documentation with examples
7. **Modern R Package**: Follows best practices for R package development

## Comparison with lme4

| Feature | lme4 | rcreg |
|---------|------|-------|
| Random effects syntax | Complex formula | Simple string argument |
| Focus | General mixed models | Longitudinal/repeated measures |
| ICC calculation | Manual | Built-in function |
| Summary output | Technical | User-friendly |
| Diagnostics | Manual | Built-in plots |
| Time centering | Manual | Built-in function |

## References

1. Fitzmaurice, G. M., Laird, N. M., & Ware, J. H. (2011). *Applied Longitudinal Analysis* (2nd ed.). Wiley.
2. Verbeke, G., & Molenberghs, G. (2000). *Linear Mixed Models for Longitudinal Data*. Springer.
3. Bates, D., Mächler, M., Bolker, B., & Walker, S. (2015). Fitting Linear Mixed-Effects Models Using lme4. *Journal of Statistical Software*, 67(1), 1-48.

## License

MIT License - See LICENSE file for details.

## Authors

[Your Name] <your.email@example.com>

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass with `devtools::test()`
5. Submit a pull request

## Contact

- GitHub: https://github.com/yourusername/rcreg
- Issues: https://github.com/yourusername/rcreg/issues
