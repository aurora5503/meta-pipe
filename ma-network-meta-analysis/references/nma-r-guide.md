# Network Meta-Analysis in R: Step-by-Step Guide

**Time**: 30-45 minutes
**Packages**: netmeta (primary), meta, metafor, ggplot2, gt
**Stage**: 06 (Analysis)

---

## Quick Start

```r
library(netmeta)

# Fit NMA from contrast-based data
net <- netmeta(TE, seTE, treat1, treat2, studlab,
               data = nma_data, sm = "RR",
               random = TRUE, method.tau = "REML")

# Visualize
netgraph(net)                    # Network geometry
forest(net, ref = "Placebo")     # Forest plot
netrank(net)                     # Treatment rankings
netleague(net)                   # League table
```

---

## Step 1: Data Preparation

NMA data can be in **contrast-based** or **arm-based** format.

### Contrast-Based Format (most common)

Each row = one comparison from one study:

| studlab | treat1 | treat2 | TE | seTE |
|---------|--------|--------|----|------|
| Trial1 | DrugA | Placebo | 0.23 | 0.11 |
| Trial2 | DrugB | Placebo | 0.35 | 0.14 |
| Trial3 | DrugA | DrugB | -0.12 | 0.16 |

- `TE`: Treatment effect (log-scale for RR/OR/HR)
- `seTE`: Standard error of TE

### Arm-Based Format

Each row = one treatment arm:

| studlab | treatment | events | n |
|---------|-----------|--------|---|
| Trial1 | DrugA | 45 | 100 |
| Trial1 | Placebo | 30 | 100 |

Convert with `pairwise()`:

```r
pw_data <- pairwise(
  treat = treatment,
  event = events,
  n = n,
  studlab = studlab,
  data = arm_data,
  sm = "RR"
)
```

---

## Step 2: Network Connectivity

Before fitting NMA, verify the network is connected:

```r
nc <- netconnection(treat1, treat2, studlab, data = nma_data)
print(nc)
# Must show: n.subnets = 1
```

If disconnected, you cannot run NMA on the full network. Options:
1. Add bridging studies
2. Analyze sub-networks separately
3. Remove isolated treatments

---

## Step 3: Network Graph

```r
net <- netmeta(TE, seTE, treat1, treat2, studlab,
               data = nma_data, sm = "RR",
               random = TRUE, method.tau = "REML")

netgraph(net,
         number.of.studies = TRUE,    # Show study counts on edges
         cex.points = 3,              # Node size
         thickness = "number.of.studies",  # Edge width
         plastic = FALSE)
```

Node size can represent number of patients; edge width represents number of studies.

---

## Step 4: Fit NMA Models

### Random-Effects (Primary)

```r
net_re <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = nma_data,
  sm = "RR",
  random = TRUE,
  fixed = FALSE,
  method.tau = "REML",
  reference.group = "Placebo"
)
summary(net_re)
```

### Fixed-Effect (Sensitivity)

```r
net_fe <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = nma_data,
  sm = "RR",
  random = FALSE,
  fixed = TRUE,
  reference.group = "Placebo"
)
```

Key output:
- `net_re$TE.random` — Treatment effect matrix
- `net_re$tau2` — Between-study variance
- `net_re$I2` — Overall heterogeneity

---

## Step 5: Inconsistency Assessment

### Design Decomposition (Global)

```r
dd <- decomp.design(net_re)
print(dd)
# Check Q_between-designs p-value
# p < 0.05 → significant inconsistency
```

### Net Heat Plot

```r
netheat(net_re, random = TRUE)
# Hot colors = inconsistency between design pairs
```

### Node-Splitting (Local)

```r
ns <- netsplit(net_re)
print(ns)
forest(ns)  # Visual comparison of direct vs indirect
```

Node-splitting compares direct and indirect estimates for each comparison. Significant p-values indicate local inconsistency.

---

## Step 6: Forest Plots

```r
# All treatments vs reference
forest(net_re,
       reference.group = "Placebo",
       sortvar = TE,
       drop.reference.group = TRUE,
       label.left = "Favours Placebo",
       label.right = "Favours treatment")
```

Export at 300 DPI:

```r
png("figures/nma_forest.png", width = 12, height = 8, units = "in", res = 300)
forest(net_re, reference.group = "Placebo", sortvar = TE)
dev.off()
```

---

## Step 7: Treatment Rankings

### P-scores

```r
ranking <- netrank(net_re, small.values = "undesirable")
print(ranking)
# P-score: 0 = worst, 1 = best
```

`small.values`: Set to `"desirable"` if lower values are better (e.g., adverse events).

### League Table

```r
league <- netleague(net_re, random = TRUE, seq = ranking, digits = 2)
print(league)
```

The league table shows all pairwise comparisons. Read row vs column.

---

## Step 8: Publication Bias

```r
# Comparison-adjusted funnel plot
funnel(net_re,
       order = ranking$Pscore.random,
       legend = TRUE)
```

Note: Standard Egger's test doesn't apply directly to NMA. The comparison-adjusted funnel plot (Chaimani & Salanti 2012) is the primary tool.

---

## Step 9: Sensitivity Analyses

### Leave-One-Out

Remove each study and refit. Check if results are robust.

### Exclude High-RoB Studies

```r
data_low_rob <- nma_data[!nma_data$studlab %in% high_rob_studies, ]
net_low_rob <- netmeta(TE, seTE, treat1, treat2, studlab,
                       data = data_low_rob, sm = "RR",
                       random = TRUE, method.tau = "REML")
```

### Bayesian Sensitivity (gemtc)

```r
library(gemtc)
network <- mtc.network(data.re = gemtc_data)
model <- mtc.model(network, type = "consistency", linearModel = "random")
results <- mtc.run(model, n.adapt = 5000, n.iter = 20000)
summary(results)
```

---

## Step 10: Export Tables

Use `gt` for publication-quality tables:

```r
library(gt)
summary_gt <- rank_df %>%
  gt() %>%
  tab_header(title = "Treatment Rankings") %>%
  fmt_number(columns = P_score, decimals = 3)

gtsave(summary_gt, "tables/nma_rankings.png", expand = 10)
```

---

## Common Pitfalls

1. **Disconnected network**: Always check with `netconnection()` first
2. **Ignoring transitivity**: Document why populations are comparable across comparisons
3. **Over-interpreting P-scores**: P-scores quantify ranking probability, not clinical significance
4. **Missing multi-arm corrections**: `netmeta()` handles multi-arm studies automatically
5. **Wrong effect scale**: Use log-scale for RR/OR/HR in `TE` column

---

## See Also

- [NMA Overview](nma-overview.md) — Decision criteria for NMA vs pairwise
- [NMA Assumptions](nma-assumptions.md) — Transitivity, consistency, homogeneity
- [NMA Reporting Checklist](nma-reporting-checklist.md) — PRISMA-NMA items
- [Package Comparison](nma-package-comparison.md) — netmeta vs alternatives
- [Package Selection](../../ma-meta-analysis/references/r-guides/09-package-selection.md) — Full R package guide
