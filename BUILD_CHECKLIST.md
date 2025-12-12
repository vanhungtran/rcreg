# Package Build and Deployment Checklist

## Pre-Build Steps

### 1. Update Package Metadata (if needed)
- [ ] Update version number in [DESCRIPTION](DESCRIPTION)
- [ ] Update authors and maintainers
- [ ] Update GitHub URLs (replace "yourusername" with actual username)
- [ ] Update email addresses
- [ ] Review and update package description

### 2. Generate Dataset
```r
# Run the data generation script
setwd("rcreg")
source("data-raw/create_data.R")

# Verify the dataset was created
file.exists("data/sim_rcr.rda")
```

### 3. Update Documentation
```r
# Load devtools
library(devtools)

# Generate documentation from roxygen2 comments
document()

# This will:
# - Update man/*.Rd files
# - Update NAMESPACE
# - Process @examples
```

### 4. Build README
```r
# If you have rmarkdown installed
rmarkdown::render("README.Rmd")

# This creates README.md from README.Rmd
```

## Testing Phase

### 5. Load Package Locally
```r
# Load all package functions
load_all()

# Test basic functionality
data(sim_rcr)
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")
rcr_summary(mod)
```

### 6. Run Unit Tests
```r
# Run all tests
test()

# Expected output: All tests should pass
# If any tests fail, fix the issues before proceeding
```

### 7. Run Package Check
```r
# Run R CMD check
check()

# Address any:
# - ERRORS (must fix)
# - WARNINGS (should fix)
# - NOTES (review, fix if possible)
```

Common issues to watch for:
- Missing documentation
- Undeclared dependencies
- Non-standard file/directory names
- Examples that take too long
- Unused imports

## Build Phase

### 8. Build Source Package
```r
# Build source package (.tar.gz)
build()

# This creates: rcreg_0.1.0.tar.gz (or similar)
```

### 9. Build Binary Package (optional)
```r
# Build binary package (.zip on Windows, .tgz on Mac)
build(binary = TRUE)
```

### 10. Install from Source
```r
# Install your built package
install.packages("../rcreg_0.1.0.tar.gz", repos = NULL, type = "source")

# Or use devtools
install()
```

## Validation Phase

### 11. Test Installed Package
```r
# Restart R session (important!)
# .rs.restartR()  # In RStudio

# Load package
library(rcreg)

# Run examples
example(rcr_fit)
example(rcr_summary)
example(rcr_predict)

# Test with fresh session
data(sim_rcr)
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")
summary_mod <- rcr_summary(mod)
print(summary_mod)
rcr_diagnostics(mod)
```

### 12. Check Documentation
```r
# View help pages
?rcr_fit
?rcr_summary
?rcr_predict
?rcr_diagnostics
?rcr_icc
?rcr_center_time
?sim_rcr

# Check that all examples run
```

### 13. Build Vignettes (if added)
```r
# Build vignettes
build_vignettes()

# View vignettes
browseVignettes("rcreg")
```

## Pre-Release Checklist

### 14. Version Control
```bash
# Initialize git repository (if not done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial package release v0.1.0"

# Create tag
git tag -a v0.1.0 -m "Version 0.1.0"
```

### 15. GitHub Setup
```bash
# Create repository on GitHub
# Then push:
git remote add origin https://github.com/yourusername/rcreg.git
git branch -M main
git push -u origin main
git push origin v0.1.0
```

### 16. Update URLs in Package
After creating GitHub repository, update these files:
- [ ] DESCRIPTION: URL and BugReports fields
- [ ] README.Rmd: Installation instructions
- [ ] All references to "yourusername"

Then rebuild documentation:
```r
document()
```

## Release Phase

### 17. Create GitHub Release
On GitHub:
1. Go to "Releases"
2. Click "Create a new release"
3. Select tag v0.1.0
4. Title: "rcreg v0.1.0 - Initial Release"
5. Description: Copy from NEWS.md
6. Attach built package files (optional)
7. Publish release

### 18. Test Installation from GitHub
```r
# In a fresh R session
remove.packages("rcreg")
devtools::install_github("yourusername/rcreg")

# Test
library(rcreg)
data(sim_rcr)
mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
               random = "intercept_slope")
rcr_summary(mod)
```

## CRAN Submission (Optional)

If you want to submit to CRAN:

### 19. CRAN Pre-checks
```r
# Check with CRAN standards
check(cran = TRUE)

# Check on multiple platforms (R-hub)
# Install rhub if needed: install.packages("rhub")
rhub::check_for_cran()

# Check on Win-builder
devtools::check_win_devel()
devtools::check_win_release()
```

### 20. CRAN Submission
```r
# Submit to CRAN
devtools::submit_cran()

# Or manually:
# 1. Go to https://cran.r-project.org/submit.html
# 2. Upload .tar.gz file
# 3. Fill out submission form
```

## Post-Release

### 21. Announcement
- [ ] Update GitHub README with installation badge
- [ ] Tweet/post about release (optional)
- [ ] Notify collaborators

### 22. Monitor
- [ ] Check GitHub issues
- [ ] Respond to user questions
- [ ] Plan next version features

## Continuous Maintenance

### For Each Update:
1. Update version number (increment appropriately)
2. Update NEWS.md with changes
3. Run full test suite
4. Run R CMD check
5. Update documentation if needed
6. Commit changes
7. Create new tag
8. Create GitHub release

### Version Numbering:
- Major version (1.0.0): Breaking changes
- Minor version (0.1.0): New features, backward compatible
- Patch version (0.1.1): Bug fixes only

## Troubleshooting Common Issues

### Issue: R CMD check fails with "Non-standard file/directory found at top level"
**Solution:** Add offending files to .Rbuildignore

### Issue: Examples take too long
**Solution:** Reduce dataset size in examples or use `\donttest{}`

### Issue: Missing imports
**Solution:** Add to DESCRIPTION Imports field and use `@importFrom` in roxygen

### Issue: Tests fail on other systems
**Solution:** Use `skip_on_cran()`, check for package availability, use appropriate tolerances

### Issue: NAMESPACE issues
**Solution:** Delete NAMESPACE and run `document()` to regenerate

## Quick Reference Commands

```r
# Essential workflow
library(devtools)

load_all()      # Load package functions
document()      # Update documentation
test()          # Run tests
check()         # Run R CMD check
build()         # Build package
install()       # Install locally

# Helpful utilities
missing_s3()    # Check for missing S3 methods
spell_check()   # Check spelling in documentation
```

## Final Verification

Before considering the package complete:
- [ ] All tests pass
- [ ] R CMD check produces 0 errors, 0 warnings, 0 notes
- [ ] All examples run without error
- [ ] Documentation is complete and accurate
- [ ] README is clear and helpful
- [ ] LICENSE is appropriate
- [ ] Version control is up to date
- [ ] Package can be installed from GitHub
- [ ] Basic workflow runs in fresh R session

## Success!

If all checks pass, your package is ready for use!

Users can install with:
```r
devtools::install_github("yourusername/rcreg")
```
