# rcreg Package Architecture

## Design Philosophy

The `rcreg` package follows these design principles:

1. **Simplicity**: Provide a high-level interface that abstracts away complex formula construction
2. **Consistency**: Use consistent naming and argument patterns across functions
3. **Transparency**: Wrap `lme4` without hiding its functionality
4. **Extensibility**: Design for easy addition of new features
5. **Best Practices**: Follow modern R package development standards

## Package Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                        │
│  (High-level functions with simplified syntax)               │
├─────────────────────────────────────────────────────────────┤
│  rcr_fit()         - Model fitting with simple random specs  │
│  rcr_summary()     - Clean, comprehensive summaries          │
│  rcr_predict()     - Predictions (subject/population level)  │
│  rcr_diagnostics() - Automated diagnostic plots              │
│  rcr_icc()         - ICC calculation                         │
│  rcr_center_time() - Time variable preprocessing            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     PROCESSING LAYER                         │
│  (S3 methods and internal logic)                             │
├─────────────────────────────────────────────────────────────┤
│  - Formula construction and validation                       │
│  - Data preprocessing and checks                             │
│  - Result formatting and structuring                         │
│  - S3 method dispatch (print, plot, coef, etc.)             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      COMPUTATIONAL CORE                      │
│  (lme4 backend)                                              │
├─────────────────────────────────────────────────────────────┤
│  lme4::lmer()      - Core mixed model fitting                │
│  lme4::fixef()     - Fixed effects extraction                │
│  lme4::ranef()     - Random effects extraction               │
│  lme4::VarCorr()   - Variance components                     │
└─────────────────────────────────────────────────────────────┘
```

## Object Model

### Primary Objects

#### 1. `rcr_mod` (S3 class)
**Created by:** `rcr_fit()`
**Purpose:** Container for fitted model and metadata

```
rcr_mod object:
├── fit              (lmerMod object from lme4)
├── formula          (original fixed-effects formula)
├── random_formula   (constructed random-effects formula string)
├── id               (name of ID variable)
├── time             (name of time variable)
├── random_type      ("intercept", "slope", or "intercept_slope")
├── data             (original data frame)
└── call             (original function call)
```

**Methods:**
- `print.rcr_mod()`
- `plot.rcr_mod()`
- `fitted.rcr_mod()`
- `residuals.rcr_mod()`
- `coef.rcr_mod()`
- `vcov.rcr_mod()`

#### 2. `rcr_summary` (S3 class)
**Created by:** `rcr_summary()`
**Purpose:** Structured summary of model results

```
rcr_summary object:
├── fixed_effects       (data.frame: estimates, SEs, CIs)
├── random_effects      (data.frame: variance components)
├── residual_variance   (numeric: σ²)
├── icc                 (numeric or list: ICC values)
├── aic                 (numeric: Akaike Information Criterion)
├── bic                 (numeric: Bayesian Information Criterion)
├── logLik              (numeric: log-likelihood)
├── nobs                (integer: number of observations)
├── ngrps               (integer: number of groups/subjects)
├── random_type         (character: type of random effects)
├── formula             (formula: fixed effects)
├── random_formula      (character: random effects)
├── id                  (character: ID variable name)
├── time                (character: time variable name)
└── call                (language: original call)
```

**Methods:**
- `print.rcr_summary()`

## Function Dependencies

```
rcr_fit()
  ├─→ validates inputs (id, time, data, formula)
  ├─→ constructs random effects formula
  ├─→ calls lme4::lmer()
  └─→ returns rcr_mod object

rcr_summary()
  ├─→ requires rcr_mod object
  ├─→ calls lme4::fixef(), VarCorr()
  ├─→ calls rcr_icc()
  ├─→ calculates confidence intervals
  └─→ returns rcr_summary object

rcr_predict()
  ├─→ requires rcr_mod object
  ├─→ calls lme4:::predict.merMod()
  ├─→ optional: computes standard errors
  └─→ returns predictions (vector or list)

rcr_diagnostics()
  ├─→ requires rcr_mod object
  ├─→ extracts residuals, fitted values
  ├─→ calls lme4::ranef()
  ├─→ produces plots using base R graphics
  └─→ returns NULL (side effect: plots)

rcr_icc()
  ├─→ requires rcr_mod object
  ├─→ calls lme4::VarCorr()
  ├─→ calculates ICC based on random_type
  └─→ returns numeric or list

rcr_center_time()
  ├─→ validates inputs
  ├─→ performs centering (global or within-subject)
  ├─→ optional: scales by SD
  └─→ returns modified data frame

rcr_ranef()
  ├─→ requires rcr_mod object
  ├─→ calls lme4::ranef()
  └─→ returns random effects (BLUPs)
```

## Data Flow

### Model Fitting Flow

```
User Data (long format)
    ↓
rcr_fit(y ~ time + x1, data, id="id", time="time", random="intercept_slope")
    ↓
Input Validation
    ├─→ Check id in data
    ├─→ Check time in data
    ├─→ Validate data frame
    └─→ Match random argument
    ↓
Formula Construction
    ├─→ Fixed: y ~ time + x1
    ├─→ Random: (1 + time | id)
    └─→ Combined: y ~ time + x1 + (1 + time | id)
    ↓
lme4::lmer(formula, data, REML=TRUE)
    ↓
lmerMod object
    ↓
Wrap in rcr_mod structure
    ↓
Return rcr_mod to user
```

### Prediction Flow

```
rcr_mod object + newdata (optional)
    ↓
rcr_predict(object, newdata, type="subject")
    ↓
Determine re.form based on type
    ├─→ "subject": re.form = NULL (include REs)
    └─→ "population": re.form = NA (exclude REs)
    ↓
lme4:::predict.merMod(object$fit, newdata, re.form)
    ↓
Optional: Calculate standard errors (population only)
    ├─→ Extract design matrix X
    ├─→ Get vcov of fixed effects
    └─→ Calculate se = sqrt(diag(X %*% V %*% t(X)))
    ↓
Return predictions (+ SEs if requested)
```

## File Organization

### Core Implementation Files

**R/rcr_fit.R** (379 lines)
- `rcr_fit()` - main fitting function
- `print.rcr_mod()` - print method
- Formula construction logic
- Input validation

**R/rcr_summary.R** (150 lines)
- `rcr_summary()` - summary function
- `print.rcr_summary()` - print method
- Fixed effects extraction and CI calculation
- Random effects extraction

**R/rcr_predict.R** (144 lines)
- `rcr_predict()` - prediction function
- `fitted.rcr_mod()` - fitted values method
- `residuals.rcr_mod()` - residuals method
- Standard error calculation

**R/rcr_diagnostics.R** (144 lines)
- `rcr_diagnostics()` - diagnostic plots
- `plot.rcr_mod()` - plot method
- Residual plots
- QQ plots for residuals and random effects

**R/rcr_helpers.R** (214 lines)
- `rcr_icc()` - ICC calculation
- `rcr_center_time()` - time centering
- `rcr_ranef()` - random effects extraction
- `vcov.rcr_mod()` - vcov method
- `coef.rcr_mod()` - coef method

**R/data.R** (74 lines)
- Documentation for `sim_rcr` dataset

**R/rcreg-package.R** (11 lines)
- Package-level documentation
- Namespace imports

## Testing Strategy

### Test Coverage

```
tests/testthat/
├── test-rcr_fit.R
│   ├─→ Random intercept model fitting
│   ├─→ Random intercept+slope model fitting
│   ├─→ Random slope only model fitting
│   ├─→ Error handling (missing variables)
│   ├─→ Input validation
│   └─→ Print method
│
├── test-rcr_summary.R
│   ├─→ Summary structure validation
│   ├─→ Component existence checks
│   ├─→ Data type validation
│   ├─→ Error handling
│   └─→ Print method
│
└── test-rcr_helpers.R
    ├─→ ICC calculation (all random types)
    ├─→ Global time centering
    ├─→ Within-subject time centering
    ├─→ Time scaling
    ├─→ Error handling
    └─→ Random effects extraction
```

### Testing Philosophy

1. **Unit Tests**: Test each function in isolation
2. **Integration Tests**: Test workflows (fit → summary → predict)
3. **Edge Cases**: Test error conditions and boundary cases
4. **Regression Tests**: Ensure consistent behavior across versions

## Extension Points

### Adding New Features

#### 1. New Random Effects Structures
Add to `rcr_fit()`:
```r
random_formula <- switch(
  random,
  intercept = "(1 | id)",
  slope = "(0 + time | id)",
  intercept_slope = "(1 + time | id)",
  nested = "(1 | id/center)",  # NEW
  crossed = "(1 | id) + (1 | time)"  # NEW
)
```

#### 2. New Summary Statistics
Add to `rcr_summary()`:
```r
out <- structure(
  list(
    # ... existing components ...
    new_statistic = compute_new_statistic(fit)  # NEW
  ),
  class = "rcr_summary"
)
```

#### 3. New Diagnostic Plots
Add to `rcr_diagnostics()`:
```r
if (5 %in% which) {  # NEW
  # New diagnostic plot
  plot(...)
}
```

#### 4. New S3 Methods
Add new methods as needed:
```r
confint.rcr_mod <- function(object, ...) {
  confint(object$fit, ...)
}
```

## Dependencies and Imports

### Direct Dependencies
- **lme4**: Core mixed model fitting (`lmer`, `fixef`, `ranef`, `VarCorr`)
- **stats**: Statistical functions (`formula`, `model.matrix`, `vcov`, etc.)
- **methods**: S3/S4 methods
- **graphics**: Plotting (`plot`, `abline`, `par`, etc.)

### Import Strategy
- Use `@importFrom` for specific functions (avoid namespace pollution)
- Re-export nothing (users can access lme4 directly if needed)
- Document when users need optional packages (ggplot2, nlme)

## Performance Considerations

### Computational Complexity
- Model fitting: O(n × p²) where n = observations, p = parameters
- ICC calculation: O(1) - just extracts variance components
- Predictions: O(n) for existing data, O(m) for new data
- Diagnostics: O(n) for plot generation

### Memory Usage
- `rcr_mod` stores original data (can be large for big datasets)
- `lmerMod` object contains substantial internal structures
- Consider: Option to not store data in `rcr_mod` for large datasets

## Future Enhancements

### Potential Additions
1. **More complex random effects structures**
   - Nested random effects
   - Crossed random effects
   - Multiple grouping factors

2. **Additional inference tools**
   - Bootstrap confidence intervals
   - Permutation tests
   - Likelihood ratio tests

3. **Enhanced diagnostics**
   - Influential observations detection
   - Outlier analysis
   - Model comparison plots

4. **Data preprocessing helpers**
   - Automatic handling of missing data
   - Time variable transformations
   - Covariate centering and scaling

5. **Alternative backends**
   - Support for `nlme` package
   - Support for Bayesian estimation (brms)

6. **Visualization enhancements**
   - ggplot2-based plotting option
   - Interactive plots (plotly)
   - Predicted trajectory plots

## Design Patterns Used

1. **Wrapper Pattern**: `rcr_fit()` wraps `lme4::lmer()`
2. **S3 Object-Oriented**: Consistent method dispatch
3. **Builder Pattern**: Constructing complex formulas from simple inputs
4. **Template Method**: `rcr_diagnostics()` allows selection of plot types
5. **Factory Pattern**: `rcr_fit()` creates `rcr_mod` objects consistently

## Naming Conventions

- **Functions**: `rcr_*` prefix for all exported functions
- **Methods**: Standard S3 method names (print, plot, coef, etc.)
- **Arguments**: Lowercase with underscores (e.g., `random_type`)
- **Classes**: `rcr_mod`, `rcr_summary`
- **Internal functions**: None currently, would use `.rcr_*` prefix

## Documentation Standards

- All exported functions have complete roxygen2 documentation
- Include `@param`, `@return`, `@details`, `@examples`
- Cross-reference related functions with `@seealso`
- Document all S3 methods
- Provide working examples that run quickly
- Include mathematical notation where appropriate

This architecture ensures the package is maintainable, extensible, and user-friendly.
