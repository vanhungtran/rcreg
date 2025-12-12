# Installation and Setup Guide for rcreg

## Prerequisites

Before installing `rcreg`, ensure you have:

1. R version 3.5.0 or later
2. The `devtools` package (for installation from source)
3. The `lme4` package (will be installed automatically as a dependency)

## Installation Steps

### Option 1: Install from GitHub (Recommended for users)

```r
# Install devtools if you don't have it
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install rcreg from GitHub
devtools::install_github("yourusername/rcreg")
```

### Option 2: Install from Local Source (For developers)

If you have the package source code locally:

```r
# Navigate to the parent directory containing rcreg/
# Then run:
devtools::install("rcreg")

# Or use:
install.packages("rcreg", repos = NULL, type = "source")
```

## Building the Package from Source

If you're developing or modifying the package:

### 1. Generate Documentation

```r
# Load necessary packages
library(devtools)
library(roxygen2)

# Set working directory to package root
setwd("path/to/rcreg")

# Generate documentation from roxygen2 comments
devtools::document()
```

### 2. Generate the Dataset

```r
# Run the data generation script
source("data-raw/create_data.R")

# This will create data/sim_rcr.rda
```

### 3. Run Tests

```r
# Load the package
devtools::load_all()

# Run all tests
devtools::test()

# Or run specific test file
testthat::test_file("tests/testthat/test-rcr_fit.R")
```

### 4. Check the Package

```r
# Run R CMD check
devtools::check()
```

### 5. Build the Package

```r
# Build source package
devtools::build()

# Build binary package
devtools::build(binary = TRUE)
```

## Verifying Installation

After installation, verify everything works:

```r
library(rcreg)

# Load example data
data(sim_rcr)
head(sim_rcr)

# Fit a simple model
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")

# View summary
rcr_summary(mod)

# If this runs without errors, installation was successful!
```

## Dependencies

The package requires the following R packages:

### Required (Imports):
- `lme4` (>= 1.1-0) - Core mixed model fitting
- `stats` - Statistical functions
- `methods` - S3/S4 methods

### Optional (Suggests):
- `ggplot2` - Enhanced plotting (optional)
- `nlme` - Alternative mixed model fitting (optional)
- `broom.mixed` - Tidy model summaries (optional)
- `testthat` (>= 3.0.0) - Unit testing
- `knitr` - Documentation
- `rmarkdown` - Documentation

## Troubleshooting

### Issue: lme4 installation fails

If `lme4` fails to install, you may need to install system dependencies:

**On Ubuntu/Debian:**
```bash
sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
```

**On macOS:**
```bash
brew install openssl
```

**On Windows:**
- Install Rtools from: https://cran.r-project.org/bin/windows/Rtools/

### Issue: Cannot load package after installation

Try:
```r
# Remove and reinstall
remove.packages("rcreg")
devtools::install_github("yourusername/rcreg")
```

### Issue: Tests fail

Make sure you have the latest version of `testthat`:
```r
install.packages("testthat")
```

## Development Workflow

For package developers:

1. **Make changes** to R code in `R/` directory
2. **Update documentation**: `devtools::document()`
3. **Load changes**: `devtools::load_all()`
4. **Test changes**: `devtools::test()`
5. **Check package**: `devtools::check()`
6. **Commit changes** to version control

## Additional Resources

- Package development guide: https://r-pkgs.org/
- roxygen2 documentation: https://roxygen2.r-lib.org/
- lme4 package: https://cran.r-project.org/package=lme4
- testthat documentation: https://testthat.r-lib.org/

## Getting Help

If you encounter issues:

1. Check the [GitHub Issues](https://github.com/yourusername/rcreg/issues)
2. Review the documentation: `?rcr_fit`
3. Post a new issue with a reproducible example
