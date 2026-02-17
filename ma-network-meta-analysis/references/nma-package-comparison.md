# NMA R Packages: Comparison Guide

**Time**: 10 minutes
**Purpose**: Choose the right R package for your network meta-analysis

---

## Quick Decision

| Your Situation | Use This | Why |
|---------------|----------|-----|
| Default NMA | **netmeta** | Fast, comprehensive, no external deps |
| Need Bayesian inference | **gemtc** | Mature, well-documented, prior flexibility |
| IPD + aggregate data | **multinma** | Modern Stan-based, handles both data types |
| Simple, quick analysis | **netmeta** | One function fits all |
| Publication for Cochrane | **netmeta** | Recommended in Cochrane Handbook |

---

## Detailed Comparison

### netmeta (Frequentist) — PRIMARY

**Version**: Actively maintained (CRAN updated Jan 2026)
**Authors**: Rücker, Schwarzer, Krahn
**Dependencies**: meta (R only, no external software)

| Feature | Support |
|---------|---------|
| Contrast-based data | Yes |
| Arm-based data | Yes (via `pairwise()`) |
| Fixed-effect model | Yes |
| Random-effects model | Yes (REML, DL, PM, ML) |
| Network graph | `netgraph()` — built-in |
| Forest plots | `forest()` — built-in |
| League table | `netleague()` |
| Rankings (P-scores) | `netrank()` |
| Inconsistency tests | `decomp.design()`, `netsplit()`, `netheat()` |
| Funnel plot | `funnel.netmeta()` (comparison-adjusted) |
| Multi-arm studies | Automatic correction |
| Component NMA | Yes (for disconnected networks) |
| Meta-regression | `netmetareg()` |

**Strengths**:
- No external dependencies (pure R)
- Comprehensive: covers entire NMA workflow
- P-scores are more interpretable than SUCRA
- Active development and community support
- Recommended by Cochrane

**Limitations**:
- Frequentist only (no posterior distributions)
- No informative priors
- Limited to standard parametric models

**Install**: `install.packages("netmeta")`

---

### gemtc (Bayesian) — SENSITIVITY

**Version**: Stable (uses JAGS backend)
**Authors**: van Valkenhoef, Kuiper
**Dependencies**: rjags, JAGS (external software required)

| Feature | Support |
|---------|---------|
| Contrast-based data | Yes |
| Arm-based data | Yes |
| Consistency model | Yes |
| Inconsistency model | Yes (unrelated mean effects) |
| Node-splitting | Yes |
| Rankings (SUCRA) | Yes |
| Prior specification | Yes (informative or vague) |
| Deviance information | DIC for model comparison |
| MCMC diagnostics | Trace plots, Gelman-Rubin |

**Strengths**:
- Full Bayesian inference with credible intervals
- Informative priors possible (useful with sparse data)
- Formal model comparison via DIC
- Well-established methodology

**Limitations**:
- Requires JAGS installation (external C++ program)
- Slower than netmeta (MCMC sampling)
- Less active development recently
- SUCRA less interpretable than P-scores
- Convergence must be manually checked

**Install**:
1. Install JAGS: https://mcmc-jags.sourceforge.io/
2. `install.packages(c("rjags", "gemtc"))`

---

### multinma (Bayesian, Modern) — ADVANCED

**Version**: Newer package (Stan backend)
**Authors**: Phillippo
**Dependencies**: Stan, rstan or cmdstanr

| Feature | Support |
|---------|---------|
| IPD + aggregate data | Yes (unique feature) |
| Contrast-based | Yes |
| Arm-based | Yes |
| Meta-regression | Yes (including IPD covariates) |
| Informative priors | Yes |
| Model comparison | LOO-IC, WAIC |
| Population adjustment | Yes (MAIC, STC) |

**Strengths**:
- Can combine individual patient data (IPD) with aggregate data
- Modern Stan backend (faster than JAGS, better diagnostics)
- Population-adjusted indirect comparisons
- Handles complex covariate adjustment

**Limitations**:
- Requires Stan installation (complex setup)
- Fewer tutorials and examples than netmeta/gemtc
- Newer package, less battle-tested
- Steeper learning curve

**Install**: `install.packages("multinma")` (requires rstan or cmdstanr)

---

## Recommendation for This Pipeline

### Primary Analysis: netmeta
- Use for all NMA analyses by default
- No external dependencies
- Produces all required outputs (network graph, forest, league table, rankings)

### Sensitivity Check: gemtc
- Run in `nma_09_sensitivity.R` if JAGS available
- Compare Bayesian vs frequentist results
- Use when reviewers request Bayesian analysis

### Advanced: multinma
- Use only when combining IPD with aggregate data
- Use when population adjustment is needed
- Requires Stan setup

---

## Feature Matrix

| Feature | netmeta | gemtc | multinma |
|---------|---------|-------|----------|
| Install difficulty | Easy | Medium (JAGS) | Hard (Stan) |
| Speed | Fast | Slow | Medium |
| Learning curve | Low | Medium | High |
| Framework | Frequentist | Bayesian | Bayesian |
| Rankings | P-scores | SUCRA | SUCRA |
| IPD support | No | No | Yes |
| Active development | Yes | Limited | Yes |
| Cochrane recommended | Yes | — | — |
| External deps | None | JAGS | Stan |

---

## See Also

- [NMA R Guide](nma-r-guide.md) — Step-by-step netmeta workflow
- [Package Selection](../../ma-meta-analysis/references/r-guides/09-package-selection.md) — Full R package guide (pairwise + NMA)
