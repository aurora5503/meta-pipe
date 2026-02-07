# R Package Selection for Meta-Analysis

**When to use**: You need to choose the right R package for your analysis
**Time**: 10-15 minutes (reading and decision)
**Stage**: 06 (Analysis planning)

---

## Quick Decision Guide

| Your Task | Use This Package | Why |
|-----------|------------------|-----|
| Calculate effect sizes | `metafor::escalc()` | Handles 50+ effect size types |
| Fit meta-analysis model | `metafor::rma()` | Gold standard, most flexible |
| Simple binary outcomes | `meta::metabin()` | Simpler syntax, auto forest plots |
| Assess heterogeneity | `metafor` | Full suite of stats + CIs |
| Publication bias | `metafor` + `dmetar` | Multiple methods available |

---

## By Analysis Stage

### 1. Effect Size Calculation

**Best: `escalc()` from metafor**

**Why**: Handles widest variety (50+ types): Cohen's d, Hedges' g, log odds ratios, correlations, risk ratios, etc. Automatically computes sampling variances.

```r
library(metafor)

# Calculate log risk ratios
es <- escalc(
  measure = "RR",
  ai = events_ici,      # Events in intervention
  n1i = total_ici,      # Total in intervention
  ci = events_control,  # Events in control
  n2i = total_control,  # Total in control
  data = data
)
```

#### Package Comparison

| Package | Strengths | Weaknesses |
|---------|-----------|------------|
| **metafor** (`escalc`) | Comprehensive, well-documented, handles nearly all ES types | Steeper learning curve |
| **esc** | Simpler syntax, good for converting between ES types | Fewer ES types supported |
| **compute.es** | Quick conversions from test statistics | No longer actively maintained |

**Recommendation**: Use `metafor::escalc()` for all projects

---

### 2. Fitting the Meta-Analytic Model

**Best: `metafor` (rma(), rma.mv())**

**Why**: Gold standard. Supports fixed-effect, random-effects (multiple tau² estimators: REML, DL, PM, etc.), and multivariate/multilevel models. Extensively validated.

```r
library(metafor)

# Random-effects model with REML
res <- rma(
  yi = yi,           # Effect sizes from escalc()
  vi = vi,           # Variances from escalc()
  data = es,
  method = "REML"    # Recommended tau² estimator
)
```

#### Package Comparison

| Package | Strengths | Weaknesses |
|---------|-----------|------------|
| **metafor** | Most flexible, multilevel models, 10+ tau² estimators, robust variance | More verbose syntax |
| **meta** | Simpler one-function interface (`metagen`, `metabin`, `metacont`), auto-generates forest plots | Less flexible for complex models |
| **rmeta** | Lightweight | Outdated, limited features |
| **bayesmeta** | Bayesian random-effects with proper priors | Narrower scope, slower |

**Recommendation**:
- **For most projects**: Use `metafor` for flexibility
- **For simple RCT meta-analysis**: Use `meta` for simpler syntax

---

### 3. Heterogeneity Assessment

**Best: `metafor`**

**Why**: Reports Q, I², H², tau², prediction intervals, and confidence intervals for heterogeneity measures. `confint()` gives CIs for tau². Supports subgroup analysis and meta-regression natively.

```r
library(metafor)

# Fit model
res <- rma(yi, vi, data = es)

# Get heterogeneity stats
print(res)  # Shows Q, I², H², tau²

# Get CI for tau²
confint(res)

# Prediction interval
predict(res)

# Subgroup analysis
res_subgroup <- rma(yi, vi, mods = ~ subgroup, data = es)
```

#### Package Comparison

| Package | Strengths | Weaknesses |
|---------|-----------|------------|
| **metafor** | Full suite of heterogeneity stats + CIs for tau² | — |
| **meta** | Reports I², tau², H; easy subgroup analyses | No CI for tau² out of the box |
| **dmetar** | Helper functions like `find.outliers()`, built on top of meta/metafor | Add-on, not standalone |

**Recommendation**: Use `metafor` for comprehensive heterogeneity assessment

---

### 4. Publication Bias

**Best: `metafor` + `dmetar` + `PublicationBias`**

**Why**: No single package dominates; each contributes unique methods.

```r
library(metafor)
library(dmetar)

# Funnel plot
funnel(res)

# Egger's test
regtest(res)

# Trim-and-fill
trimfill(res)

# P-curve (via dmetar)
pcurve(res)
```

#### Package Comparison

| Package | What it does best |
|---------|-------------------|
| **metafor** | Funnel plots, Egger's test (`regtest()`), trim-and-fill (`trimfill()`), selection models (`selmodel()`) |
| **dmetar** | Convenient wrappers: `pcurve()`, limit meta-analysis |
| **PublicationBias** | Sensitivity analysis (Mathur & VanderWeele methods), robust to selection model assumptions |
| **weightr** | Vevea-Hedges weight-function models for selection |

**Recommendation**:
- Use `metafor` for standard methods (funnel plot, Egger's, trim-and-fill)
- Add `dmetar` for p-curve and limit meta-analysis
- Use `PublicationBias` for sensitivity analysis

---

## Installation

```r
# Core packages (install first)
install.packages(c("metafor", "meta"))

# Additional packages (install as needed)
install.packages(c("dmetar", "weightr"))

# PublicationBias (from CRAN)
install.packages("PublicationBias")
```

---

## Common Scenarios

### Scenario 1: Simple RCT Meta-Analysis (Binary Outcome)

**Use: `meta` package**

```r
library(meta)

# Simple interface
res <- metabin(
  event.e = events_ici,
  n.e = total_ici,
  event.c = events_control,
  n.c = total_control,
  data = data,
  studlab = study_id,
  sm = "RR",
  method = "MH"
)

# Auto-generate forest plot
forest(res)
```

**Why meta not metafor**: Simpler syntax, automatic forest plots, perfect for straightforward RCT meta-analysis.

---

### Scenario 2: Complex Meta-Analysis (Multilevel, Meta-Regression)

**Use: `metafor` package**

```r
library(metafor)

# Calculate effect sizes
es <- escalc(measure = "RR",
             ai = events_ici, n1i = total_ici,
             ci = events_control, n2i = total_control,
             data = data)

# Multilevel model (trials nested within studies)
res <- rma.mv(
  yi, vi,
  random = ~ 1 | study_id/trial_id,
  data = es
)

# Meta-regression with covariates
res_mr <- rma(
  yi, vi,
  mods = ~ age + pdl1_status,
  data = es
)
```

**Why metafor not meta**: Supports multilevel models, meta-regression, multiple tau² estimators.

---

### Scenario 3: Comprehensive Publication Bias Assessment

**Use: `metafor` + `dmetar` + `PublicationBias`**

```r
library(metafor)
library(dmetar)
library(PublicationBias)

# Fit model
res <- rma(yi, vi, data = es)

# 1. Visual inspection
funnel(res)

# 2. Statistical tests
regtest(res)  # Egger's test

# 3. Trim-and-fill
trimfill(res)

# 4. P-curve
pcurve(res)

# 5. Sensitivity analysis (PublicationBias)
# (See PublicationBias documentation)
```

---

## Package Documentation

### Core Packages

- **metafor**: https://www.metafor-project.org/
  - Most comprehensive documentation
  - 100+ pages of tutorials
  - Extensively validated

- **meta**: https://cran.r-project.org/web/packages/meta/
  - Simpler interface
  - Good for beginners
  - Excellent vignettes

### Specialized Packages

- **dmetar**: https://dmetar.protectlab.org/
  - Companion to "Doing Meta-Analysis in R" book
  - Helper functions built on meta/metafor

- **PublicationBias**: https://cran.r-project.org/web/packages/PublicationBias/
  - Mathur & VanderWeele methods
  - Sensitivity analysis tools

- **weightr**: https://cran.r-project.org/web/packages/weightr/
  - Vevea-Hedges selection models

---

## Tau² Estimators

When using `metafor`, you can choose from 10+ tau² estimators:

| Estimator | When to use | Code |
|-----------|-------------|------|
| **REML** | Default, most reliable | `method = "REML"` |
| **DL** | Older studies, comparison | `method = "DL"` |
| **PM** | Alternative to REML | `method = "PM"` |
| **ML** | Maximum likelihood | `method = "ML"` |

**Recommendation**: Use REML (Restricted Maximum Likelihood) unless you have specific reason otherwise.

```r
# Compare tau² estimators
res_reml <- rma(yi, vi, data = es, method = "REML")
res_dl <- rma(yi, vi, data = es, method = "DL")
res_pm <- rma(yi, vi, data = es, method = "PM")

# Compare results
rbind(
  REML = c(tau2 = res_reml$tau2, I2 = res_reml$I2),
  DL = c(tau2 = res_dl$tau2, I2 = res_dl$I2),
  PM = c(tau2 = res_pm$tau2, I2 = res_pm$I2)
)
```

---

## Decision Flowchart

```
Start: What's your analysis?
├─ Simple RCT (binary/continuous)
│  └─ Use meta (metabin, metacont)
│
├─ Need multilevel models?
│  └─ Use metafor (rma.mv)
│
├─ Need meta-regression?
│  └─ Use metafor (rma with mods)
│
├─ Need specific tau² estimator?
│  └─ Use metafor (rma with method)
│
└─ Publication bias assessment?
   └─ Use metafor + dmetar + PublicationBias
```

---

## Common Mistakes

### ❌ Don't: Use compute.es

**Why**: No longer actively maintained, outdated.

**Do instead**: Use `metafor::escalc()` or `esc` package.

### ❌ Don't: Use rmeta

**Why**: Outdated, limited features, superseded by meta and metafor.

**Do instead**: Use `meta` or `metafor`.

### ❌ Don't: Use only funnel plot for publication bias

**Why**: Visual inspection alone is insufficient.

**Do instead**: Combine multiple methods:
- Funnel plot (visual)
- Egger's test (statistical)
- Trim-and-fill (correction)
- P-curve (alternative)

---

## Quick Reference

```r
# === EFFECT SIZE CALCULATION ===
library(metafor)
es <- escalc(measure = "RR", ai, n1i, ci, n2i, data = data)

# === MODEL FITTING ===
# Simple
library(meta)
res <- metabin(event.e, n.e, event.c, n.c, data = data)

# Complex
library(metafor)
res <- rma(yi, vi, data = es, method = "REML")

# === HETEROGENEITY ===
print(res)        # Q, I², H², tau²
confint(res)      # CI for tau²
predict(res)      # Prediction interval

# === PUBLICATION BIAS ===
funnel(res)       # Visual
regtest(res)      # Egger's test
trimfill(res)     # Trim-and-fill
```

---

## See Also

- [01-forest-plots.md](01-forest-plots.md) - Create forest plots with meta/metafor
- [02-funnel-plots.md](02-funnel-plots.md) - Publication bias assessment
- [03-subgroup-plots.md](03-subgroup-plots.md) - Subgroup analysis
- [00-setup.md](00-setup.md) - Package installation

---

**Key Takeaway**:
- Use **meta** for simple, straightforward meta-analysis (easier syntax)
- Use **metafor** for complex models and maximum flexibility
- Use **both** for publication bias (funnel plots, Egger's, trim-and-fill, p-curve)
