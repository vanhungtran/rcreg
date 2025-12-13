# Random Coefficient Regression Models for Repeated Measurements: A Comprehensive Review

Random coefficient regression models, also known as mixed-effects models with random slopes and intercepts, represent a powerful and flexible framework for analyzing repeated measurement data where measurements are nested within subjects. These models allow the relationship between a response variable and covariates to vary across individuals, capturing both population-level trends and subject-specific deviations. This review synthesizes the theoretical foundations, methodological approaches, estimation techniques, and practical applications of random coefficient regression models in the context of repeated measures studies.

## Theoretical Foundations and Model Specification

### Basic Model Structure

A random coefficient regression model specifies that both the regression intercept and the slope(s) can vary across subjects, departing from the restrictive assumption of ordinary regression where these parameters are fixed across all observational units. In the context of repeated measurements, these models belong to the broader class of linear mixed models and are also known as multilevel or hierarchical models when measurements are nested within subjects.[^1_1][^1_2]

The general specification for a random coefficient regression model with repeated measures can be expressed as follows. For subject $i$ at time point $j$, the model takes the form:

$$
y_{ij} = \beta_0 + \beta_1 x_{ij} + u_{0i} + u_{1i} x_{ij} + \varepsilon_{ij}
$$

where $y_{ij}$ is the response for subject $i$ at occasion $j$, $\beta_0$ and $\beta_1$ are fixed effects representing population-level intercept and slope, $x_{ij}$ represents the time variable or covariate, $u_{0i}$ is the random intercept deviation for subject $i$, $u_{1i}$ is the random slope deviation for subject $i$, and $\varepsilon_{ij}$ is the residual error. The critical feature distinguishing random coefficient models from simpler random effects models is the allowance for **correlation between the random intercept and random slope**, which reflects the empirical reality that subjects with higher baseline levels often exhibit different rates of change.[^1_3][^1_4][^1_1]

The random effects are typically assumed to follow a bivariate normal distribution:[^1_1][^1_3]

$$
\begin{pmatrix} u_{0i} \\ u_{1i} \end{pmatrix} \sim N\left(0, \mathbf{G}\right)
$$

where the covariance matrix **G** is specified as:

$$
\mathbf{G} = \begin{pmatrix} \sigma^2_{u_0} & \sigma_{u_0, u_1} \\ \sigma_{u_0, u_1} & \sigma^2_{u_1} \end{pmatrix}
$$

This bivariate structure allows the model to capture the covariance between intercepts and slopes, which is essential for accurate inference in studies where subject-specific baseline levels and trajectories are naturally correlated. Without this correlation structure, the model would fail to capture important aspects of individual heterogeneity in longitudinal data.[^1_4][^1_1]

### Key Advantages Over Alternative Approaches

Random coefficient models offer several advantages compared to traditional approaches for analyzing repeated measures data. Unlike univariate repeated measures ANOVA, which requires balanced designs with complete data at fixed time points, random coefficient regression accommodates unbalanced designs with missing data, variable follow-up times, and unequally spaced measurement occasions. This flexibility is particularly valuable in clinical trials and observational studies where missing data is common and measurement schedules often vary across subjects.[^1_3][^1_4][^1_1]

Furthermore, random coefficient models explicitly model the within-subject correlation structure, addressing the violation of independence assumptions inherent in standard regression approaches. By partitioning variance into between-subject and within-subject components, these models provide more efficient parameter estimates and appropriate inference compared to methods that ignore the hierarchical structure of repeated measures data.[^1_2][^1_1]

## Variance-Covariance Structure and Model Specification

### Residual Covariance Structures

An essential component of random coefficient models is the specification of the residual variance-covariance structure, captured by the **R** matrix. While random coefficient models naturally induce a particular covariance structure through the random intercept and slope terms, the specification of the residual error structure provides additional flexibility in modeling within-subject dependencies.[^1_4][^1_1]

The **R** matrix can take various parametric forms, each with different implications for the correlation between repeated measurements. Common structures include:[^1_5][^1_4]

- **Diagonal**: Assumes independent residuals with constant variance, the simplest specification
- **Compound Symmetry**: Assumes constant correlation between all pairs of measurements on the same subject
- **First-order Autoregressive AR(1)**: Assumes correlation that decreases with time distance between measurements
- **Toeplitz**: Allows different correlations based on the lag between measurements
- **Unstructured**: Estimates all unique variances and covariances without constraints, most flexible but requires many parameters[^1_4]

The choice of covariance structure should balance model complexity with parsimony. Model selection criteria such as Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC) can guide this choice, with the recommendation to start with simpler structures and progressively test more complex alternatives.[^1_4]

### Partition of Variance

A fundamental insight of random coefficient models is their ability to decompose total variance into identifiable components. In the pain trial example presented in one methodological reference, the variance parameters estimated were: subject-level variance (random intercept) of 9.44, subject-by-time variance (random slope) of 1.38, and residual variance of 27.61. This decomposition reveals that approximately 25% of the total variance (9.44/(9.44+1.38+27.61)) is attributable to stable differences between subjects, while the majority reflects within-subject variation and measurement error.[^1_1][^1_4]

The correlation between random intercepts and slopes provides additional insight into subject-level heterogeneity. A negative correlation between intercept and slope, as observed in many longitudinal studies, indicates that subjects with higher baseline measurements tend to show steeper declines over time—a pattern observed in weight loss studies where individuals with higher initial weight lose weight faster. This information would be completely lost if the model specified fixed slopes across subjects.[^1_6]

## Estimation Methods and Likelihood-Based Inference

### Maximum Likelihood and Restricted Maximum Likelihood

Random coefficient regression models are typically estimated using either Maximum Likelihood (ML) or Restricted Maximum Likelihood (REML) estimation. REML provides a methodological advantage by accounting for the loss of degrees of freedom when estimating fixed effects, yielding less biased variance component estimates—particularly important when the number of fixed effects is substantial relative to sample size. ML estimation allows direct comparison of models with different fixed effects structures through likelihood ratio tests, which REML-based comparisons do not support unless the models are nested with identical fixed effects.[^1_7][^1_8][^1_9][^1_4]

Recent reviews of REML estimation in generalized linear mixed models indicate that multiple equivalent approaches to REML—including approximate linearization, integrated likelihood, modified profile likelihoods, and direct bias correction—produce similar results in finite samples. The convergence of these methods to comparable solutions suggests the robustness of REML approaches across different implementation strategies.[^1_7]

### Estimation Algorithms and Convergence

Numerical optimization for mixed models typically employs Newton-Raphson algorithms with Fisher-Scoring iterations as the initial optimization phase. In practice, estimation software such as ASReml-R 4, NCSS, nlme in R, and lme4 in R use specialized algorithms that efficiently handle the high-dimensional parameter spaces inherent in mixed models. The Newton-Raphson algorithm includes adaptive features to prevent boundary violations (e.g., negative variance estimates) through lambda adjustments, where the step size is reduced by factors of 2 if parameters become infeasible.[^1_9][^1_4]

Diagnostic convergence indicators include the log-likelihood value, the number of iterations required, and whether the algorithm reached the maximum number of allowed iterations. Normal convergence occurs when the algorithm achieves a stationary point before reaching computational limits, though non-convergence does not necessarily indicate model misspecification—it may reflect data characteristics or suboptimal starting values.[^1_10]

## Statistical Inference and Hypothesis Testing

### Fixed Effects Inference

Testing fixed effects in random coefficient models follows principles from mixed model theory, with adjustments necessary because denominator degrees of freedom are not straightforward functions of sample size. The Kenward-Roger approximation, widely implemented in statistical software, provides robust degree-of-freedom corrections that improve inference in small samples.[^1_11][^1_9][^1_4]

Wald F-tests for fixed effects compare model coefficients to their estimated standard errors, using the Kenward-Roger adjusted denominator degrees of freedom. For example, in a postpartum depression trial with 63 subjects and 6 repeated measurements, hypothesis tests for treatment effects, time effects, and their interactions yielded denominator degrees of freedom that varied substantially (ranging from approximately 4 to 100), reflecting the information available for estimating each parameter.[^1_4]

### Variance Component Testing and Model Comparison

Testing whether random slopes are necessary—versus fitting models with only random intercepts—involves comparing nested models using likelihood ratio tests or information criteria. The restricted likelihood ratio test (RLRT) employs an asymptotic null distribution that is a 50:50 mixture of a point mass at zero and a chi-square distribution with 1 degree of freedom, accounting for the boundary constraint that variance components must be non-negative.[^1_12][^1_7]

Bayesian approaches using Bayes factors provide an alternative to frequentist hypothesis tests for model comparison, with simulation studies indicating competitive power and Type I error rates compared to RLRT approaches. A simulation study examining power to detect random slopes across different sample sizes (n = 50 to 1000) showed that with n = 100 and a true slope variance of 0.30 (on a standardized scale), Bayes factors achieved approximately 47% power, comparable to the 43% power achieved by RLRT.[^1_12]

## Advanced Extensions and Modeling Approaches

### Polynomial and Nonlinear Growth Curves

Extensions of random coefficient models accommodate nonlinear trajectories through polynomial specifications and functional forms. Growth curve models commonly employ quadratic or cubic polynomial structures where the constant, linear, and quadratic coefficients all vary randomly across subjects. For example, a polynomial growth model with random coefficients can specify:[^1_13][^1_14]

$$
y_{ij} = (\beta_0 + u_{0i}) + (\beta_1 + u_{1i})x_{ij} + (\beta_2 + u_{2i})x_{ij}^2 + \varepsilon_{ij}
$$

This specification allows each subject to have a unique parabolic trajectory while sharing the population-level nonlinear form. In height growth studies, such models can capture the typical adolescent growth pattern while allowing individual variation in timing and magnitude of growth spurts.[^1_14][^1_13]

### Functional Random Slope Models

More sophisticated extensions relax the assumption of a linear relationship between random intercepts and slopes. Functional random slope models employ nonparametric smoothing to estimate the relationship between intercepts and slopes without assuming linearity. These models are particularly valuable when scientific interest focuses on understanding whether the rate of change depends on baseline level in a manner that violates the bivariate normality assumption.[^1_15]

Simulation studies comparing functional slope models to standard random intercepts-slopes models show substantial improvements in mean squared error (10-35% for n=100, 50-60% for n=200) when the true functional form is nonlinear. This improvement comes from explicitly correcting for shrinkage toward linearity induced by the parametric bivariate normal prior.[^1_15]

### Heterogeneous Covariance Structure Models

Recent methodological advances allow the random effects covariance matrix to vary as a function of measured covariates using Cholesky decomposition of the covariance matrix. This extension is particularly useful in studies where heterogeneity in baseline-slope correlation differs across treatment groups or demographic subgroups, situations where the standard homogeneous covariance assumption may be inadequate.[^1_16]

## Practical Considerations: Sample Size, Power, and Missing Data

### Power and Sample Size Determination

Determining required sample sizes for studies employing random coefficient models involves more complex calculations than standard designs due to the multiple variance components and hierarchical data structure. Current approaches present variance, power, and sample size formulae accounting for missing data and variable follow-up times.[^1_17]

A key insight from power analysis in random coefficient designs is that power depends critically on the number of repeated measurements per subject, not just the number of subjects. For a given total sample of observations, designs with fewer subjects and more measurements per subject often achieve higher power than designs with more subjects and fewer measurements. This trade-off reflects the fact that within-subject variance components (including residual error) are estimated primarily from within-subject variation across time.[^1_17]

An R Shiny application implementing power and sample size calculations for random coefficient models enables researchers to explore designs across different specifications of variance components, missing data percentages, and follow-up schedules. Such tools are essential for realistic study planning, as they accommodate the practical constraints of longitudinal studies where complete data collection is often infeasible.[^1_17]

### Handling Missing Data

Random coefficient models naturally accommodate missing data through likelihood-based inference, avoiding the biases associated with listwise deletion when data are missing at random (MAR). The likelihood function integrates over missing observations, leveraging all available information from partially complete subjects.[^1_18][^1_1][^1_4]

However, missing data can complicate variance component estimation if the missing data mechanism is not ignorable (i.e., depends on unobserved values). Methods for handling missing data in regression contexts include Predictive Mean Matching and imputation-based approaches, with Predictive Mean Matching showing superior performance in preserving bias and coverage properties across multiple imputation scenarios. For random coefficient models specifically, multiple imputation followed by standard analysis using complete-data methods provides valid inference under MAR assumptions, provided imputations are repeated across multiple datasets and parameter estimates are appropriately pooled.[^1_19][^1_8]

## Software Implementation and Computational Tools

### R Packages and Implementation

Several R packages implement random coefficient models with specialized features. The **nlme** package allows specification of complex residual covariance structures (R matrix) and is required for models that relax the exchangeability assumption. The **lme4** package provides computationally efficient fitting of models assuming exchangeable within-subject covariance, with excellent visualization and model evaluation tools. For robust estimation addressing outliers and model violations, the **robustlmm** package extends lme4 methodology.[^1_9]

Model specification in lme4 employs intuitive formula notation: a random intercept and slope model with potential correlation is specified as `y ~ time + (1 + time | subject)`, while a model with uncorrelated random effects uses `(1 | subject) + (0 + time | subject)`[^1_9]. This flexible syntax accommodates a wide variety of random effects structures.

### Other Statistical Platforms

Beyond R, specialized software includes ASReml-R 4 for generalized mixed models with extensive covariance structure options, and NCSS statistical software which provides a streamlined user interface specifically designed for random coefficient models, automatically simplifying model specification compared to general mixed model procedures. These platforms implement equivalent mathematical specifications but may differ in default optimization algorithms, convergence criteria, and available post-estimation diagnostics.[^1_4]

## Applications and Case Studies

### Clinical Trial Applications

A canonical application of random coefficient models is post-operative pain assessment in clinical trials. In a placebo-controlled trial comparing two analgesic drugs to placebo with 7 subjects per group and pain measured at 30-minute intervals for 3 hours, a random coefficient model specified treatment and time as fixed effects (with interaction) while allowing individual subjects to have random intercepts and slopes. Results showed a significant treatment-by-time interaction, indicating that drug efficacy (rate of pain reduction) differed between the two active treatments and placebo. The estimated correlation between random intercepts and slopes was -0.57, indicating that subjects with higher baseline pain showed faster pain reduction.[^1_4]

### Longitudinal Growth Studies

Random coefficient models are extensively applied to growth and development studies. The classic Potthoff-Roy orthodontic growth data analyzed 27 children followed from ages 8 to 14 years with measurements every 2 years. Random coefficient models allowing sex-specific fixed effects for both intercept and slope while specifying random intercept and slope for each child captured substantial individual heterogeneity in growth trajectories. More sophisticated polynomial growth models extend this framework, as illustrated in Edinburgh height growth data where random coefficients in polynomial functions (up to cubic terms) accommodate the complex nonlinear growth patterns during adolescence.[^1_14][^1_1]

### Microbiome and Longitudinal Biomarker Studies

Emerging applications in biomarker discovery leverage random coefficient models for longitudinal metabolomic and proteomic studies, where repeated measurements of biomarkers are collected from individual subjects across time. The flexibility to accommodate unequally-spaced measurements and subject-level heterogeneity makes these models particularly valuable when biomarker evolution patterns differ substantially across individuals or disease subgroups.[^1_20][^1_21]

## Diagnostic Assessment and Model Checking

### Residual Analysis

Comprehensive model assessment requires examination of both marginal residuals (observed minus fitted values from the marginal model) and conditional residuals (observed minus predicted values incorporating subject-specific random effects). Marginal residuals diagnose misspecification of fixed effects and the average variance-covariance structure, while conditional residuals assess assumptions about random effects distributions and residual variance.[^1_11]

Diagnostic tools include standard residual plots (residuals versus fitted values, normal probability plots), leverage diagnostics identifying influential observations, and local influence diagnostics quantifying how small perturbations to the model would affect parameter estimates. Specific to mixed models, case-deletion diagnostics assess whether individual subjects substantially influence variance component estimates—information not available in standard regression residual analysis.[^1_11]

### Remedial Measures for Assumption Violations

When diagnostic assessment reveals violations of model assumptions (e.g., non-normality of random effects, heterogeneous residual variance across time), several approaches are available. Model extensions include generalized linear mixed models for non-normal response distributions, elliptically-symmetric distributions as robust alternatives to multivariate normality, Generalized Estimating Equations (GEE) for semi-parametric inference, and variance function models allowing residual variance to depend on the mean.[^1_22]

## Conclusion and Future Directions

Random coefficient regression models provide a principled, flexible framework for analyzing repeated measurement data that accommodates realistic study designs with unbalanced data, missing values, and unequally-spaced measurements. The foundational insight that both intercepts and slopes vary across subjects, with potential correlation between these random effects, captures essential features of individual heterogeneity often overlooked in simpler analytical approaches.[^1_1][^1_4]

Recent advances extend these models through polynomial and nonparametric functional forms, heterogeneous covariance structures, and Bayesian implementations incorporating prior information about variance components. Continued methodological development addresses challenges in model selection, small-sample inference, complex missing data mechanisms, and computational efficiency for high-dimensional longitudinal data.[^1_16][^1_15][^1_7][^1_14]

For practitioners, the availability of user-friendly software and established diagnostic procedures has made random coefficient models increasingly accessible beyond specialized statistical audiences. Whether applied to clinical trials, epidemiological cohort studies, or biomarker discovery research, these models remain essential tools for extracting maximum information from expensive-to-collect longitudinal data while providing honest uncertainty quantification for subject-level heterogeneity in treatment response and disease progression.[^1_9][^1_1][^1_23]
<span style="display:none">[^1_24][^1_25][^1_26][^1_27][^1_28][^1_29][^1_30]</span>

<div align="center">⁂</div>

[^1_1]: https://vsni.co.uk/random-coefficient-regression-models/

[^1_2]: https://www.youtube.com/watch?v=EgoiWImcg4s

[^1_3]: https://www.ncss.com/wp-content/themes/ncss/pdf/Procedures/NCSS/Mixed_Models-Random_Coefficients.pdf

[^1_4]: https://vsni.co.uk/lmm-for-longitudinal-clinical-trial-data/

[^1_5]: https://cran.r-project.org/web/packages/mmrm/vignettes/covariance.html

[^1_6]: https://www.youtube.com/watch?v=oI1_SV1Rpfc

[^1_7]: https://arxiv.org/abs/2402.12719

[^1_8]: https://pmc.ncbi.nlm.nih.gov/articles/PMC5841569/

[^1_9]: https://statisticalhorizons.com/wp-content/uploads/LDA-R-Sample-Materials-9.pdf

[^1_10]: https://www.repository.cam.ac.uk/bitstreams/f3f35483-f214-4928-9fa7-beea6a2a9e9a/download

[^1_11]: https://www.statistics.gov.hk/wsc/CPS203-P28-S.pdf

[^1_12]: https://pmc.ncbi.nlm.nih.gov/articles/PMC3136354/

[^1_13]: https://grodri.github.io/multilevel/pop510slides4.pdf

[^1_14]: https://www.bristol.ac.uk/media-library/sites/cmm/migrated/documents/Level 1 variance growth modelling.pdf

[^1_15]: https://pmc.ncbi.nlm.nih.gov/articles/PMC4446058/

[^1_16]: https://pmc.ncbi.nlm.nih.gov/articles/PMC2747645/

[^1_17]: https://pubmed.ncbi.nlm.nih.gov/33586212/

[^1_18]: https://bookdown.org/mike/data_analysis/methods-for-handling-missing-data.html

[^1_19]: https://www.diva-portal.org/smash/get/diva2:1520218/FULLTEXT01.pdf

[^1_20]: https://academic.oup.com/biostatistics/article/12/2/270/280672

[^1_21]: https://pmc.ncbi.nlm.nih.gov/articles/PMC6015946/

[^1_22]: https://arxiv.org/pdf/0803.4112.pdf

[^1_23]: http://www2.compute.dtu.dk/courses/02429/enotepdfs/eNote-9.pdf

[^1_24]: https://www.sciencedirect.com/topics/mathematics/random-coefficient-model

[^1_25]: https://journals.sagepub.com/doi/10.1177/0008068319960306

[^1_26]: https://www.jstor.org/stable/2530064

[^1_27]: https://pmc.ncbi.nlm.nih.gov/articles/PMC10705229/

[^1_28]: https://groups.google.com/g/lavaan/c/WkatsB2zhkg

[^1_29]: https://resolve.cambridge.org/core/journals/psychometrika/article/unified-approach-to-power-calculation-and-sample-size-determination-for-random-regression-models/3DA98BD298CDF2A6B474F37FCA2BECA7

[^1_30]: https://pmc.ncbi.nlm.nih.gov/articles/PMC5398961/
