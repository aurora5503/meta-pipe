# Forest Plots for Meta-Analysis

**When to use**: You have extracted data and need to visualize pooled effect sizes
**Time**: 15-30 minutes
**Stage**: 06 (Analysis)

**Packages**:

```r
library(meta)      # Simple forest plots
library(metafor)   # Advanced forest plots
library(ggplot2)   # Custom forest plots
library(ggsci)     # Journal colors
```

---

## Quick Start: Binary Outcomes (RR, OR)

```r
library(meta)

# Read your extraction data
data <- read.csv("05_extraction/extraction.csv")

# Calculate risk ratios
res <- metabin(
  event.e = events_ici,        # Events in intervention group
  n.e = total_ici,             # Total in intervention group
  event.c = events_control,    # Events in control group
  n.c = total_control,         # Total in control group
  data = data,
  studlab = study_id,
  sm = "RR",                   # Summary measure: RR, OR, or RD
  method = "MH"                # Mantel-Haenszel method
)

# Create forest plot
png("figures/forest_plot.png", width=10, height=8, units="in", res=300)
forest(res)
dev.off()
```

**Done!** You now have a publication-quality forest plot at 300 DPI.

---

## Quick Start: Continuous Outcomes (HR, SMD)

```r
library(meta)

# For hazard ratios (survival data)
res <- metagen(
  TE = log_hr,           # Log hazard ratio
  seTE = se_log_hr,      # Standard error of log HR
  data = data,
  studlab = study_id,
  sm = "HR"
)

# For standardized mean differences
res <- metacont(
  n.e = n_intervention,
  mean.e = mean_intervention,
  sd.e = sd_intervention,
  n.c = n_control,
  mean.c = mean_control,
  sd.c = sd_control,
  data = data,
  studlab = study_id,
  sm = "SMD"
)

# Create forest plot (same as above)
png("figures/forest_plot.png", width=10, height=8, units="in", res=300)
forest(res)
dev.off()
```

---

## Customization Options

### Add Journal Colors

```r
library(ggsci)

# Get Lancet colors
lancet_colors <- pal_lancet()(2)

png("figures/forest_plot.png", width=10, height=8, units="in", res=300)
forest(res,
       col.square = lancet_colors[1],     # Study squares
       col.diamond = lancet_colors[2],    # Pooled diamond
       print.I2 = TRUE,                   # Show heterogeneity
       print.pval.Q = TRUE)               # Show Q-test p-value
dev.off()
```

### Control Axes

```r
forest(res,
       xlim = c(0.5, 2.0),          # X-axis limits
       xlab = "Risk Ratio",         # X-axis label
       leftcols = c("studlab", "n.e", "n.c"),  # Left columns
       rightcols = c("effect", "ci"))           # Right columns
```

### Fixed vs Random Effects

```r
# Show only random effects
forest(res,
       comb.fixed = FALSE,    # Hide fixed effect
       comb.random = TRUE)    # Show random effect

# Show both
forest(res,
       comb.fixed = TRUE,
       comb.random = TRUE)
```

---

## Common Scenarios

### Scenario 1: RCT Meta-Analysis (Binary Outcome)

**Data**: You have events and totals for each arm

```r
library(meta)

data <- read.csv("05_extraction/extraction.csv")

res <- metabin(
  event.e = pcr_ici,
  n.e = total_ici,
  event.c = pcr_control,
  n.c = total_control,
  data = data,
  studlab = study_id,
  sm = "RR",
  method = "MH",
  fixed = FALSE,      # Don't compute fixed effect
  random = TRUE       # Compute random effect
)

# Professional forest plot
png("06_analysis/figures/figure1_pcr.png",
    width = 10, height = 8, units = "in", res = 300)

forest(res,
       xlim = c(0.5, 2.0),
       xlab = "Risk Ratio (ICI vs Control)",
       studlab = TRUE,
       comb.fixed = FALSE,
       comb.random = TRUE,
       print.I2 = TRUE,
       print.pval.Q = TRUE,
       col.square = pal_lancet()(1),
       col.diamond = pal_lancet()(2))

dev.off()
```

### Scenario 2: Survival Data (HR)

**Data**: You have log hazard ratios and standard errors

```r
library(meta)

data <- read.csv("05_extraction/extraction.csv")

res_efs <- metagen(
  TE = log_hr_efs,          # Log hazard ratio for EFS
  seTE = se_log_hr_efs,     # Standard error
  data = data,
  studlab = study_id,
  sm = "HR",
  method.tau = "REML"       # REML for between-study variance
)

png("06_analysis/figures/figure2_efs.png",
    width = 10, height = 8, units = "in", res = 300)

forest(res_efs,
       xlab = "Hazard Ratio (ICI vs Control)",
       xlim = c(0.5, 1.5),
       comb.fixed = FALSE,
       comb.random = TRUE)

dev.off()
```

### Scenario 3: Custom ggplot2 Forest Plot

**When**: You need more control over appearance

```r
library(ggplot2)
library(dplyr)
library(ggsci)
library(hrbrthemes)

# Extract data from meta-analysis object
forest_data <- data.frame(
  study = data$study_id,
  rr = exp(res$TE),
  ci_lower = exp(res$TE - 1.96 * res$seTE),
  ci_upper = exp(res$TE + 1.96 * res$seTE),
  weight = res$w.random
) %>%
  arrange(desc(weight))

# Create ggplot forest plot
p <- ggplot(forest_data, aes(x = rr, y = reorder(study, weight))) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
  geom_point(aes(size = weight), color = pal_lancet()(1)) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
  scale_x_log10(breaks = c(0.5, 0.75, 1.0, 1.5, 2.0)) +
  scale_size_continuous(range = c(3, 8), guide = "none") +
  theme_ipsum_rc() +
  labs(
    title = "Forest Plot: Pathologic Complete Response",
    subtitle = "Risk ratio with 95% CI (5 RCTs, N=2,402)",
    x = "Risk Ratio (log scale)",
    y = NULL
  )

ggsave("06_analysis/figures/figure1_custom.png",
       width = 10, height = 6, dpi = 300)
```

---

## Troubleshooting

### Problem: "Error in metabin: invalid arguments"

**Cause**: Missing or NA values in data

**Solution**: Check for missing data

```r
# Check for missing values
sum(is.na(data$events_ici))
sum(is.na(data$total_ici))

# Remove rows with missing data
data_clean <- data %>%
  filter(!is.na(events_ici), !is.na(total_ici),
         !is.na(events_control), !is.na(total_control))
```

### Problem: Forest plot text too small

**Solution**: Increase plot dimensions

```r
png("forest.png", width=12, height=10, units="in", res=300)
forest(res)
dev.off()
```

### Problem: Studies in wrong order

**Solution**: Order by effect size or weight

```r
# Order by effect size (ascending)
forest(res, sortvar = TE)

# Order by weight (descending)
forest(res, sortvar = -w.random)
```

---

## Export Formats

### PNG (Recommended)

```r
png("figure.png", width=10, height=8, units="in", res=300)
forest(res)
dev.off()
```

### PDF (Vector graphics)

```r
pdf("figure.pdf", width=10, height=8)
forest(res)
dev.off()
```

### TIFF (Some journals require)

```r
tiff("figure.tif", width=10, height=8, units="in", res=300, compression="lzw")
forest(res)
dev.off()
```

---

## Package Documentation

- **meta**: https://cran.r-project.org/web/packages/meta/
- **metafor**: https://www.metafor-project.org/
- **ggsci**: https://cran.r-project.org/web/packages/ggsci/

---

## See Also

- [02-funnel-plots.md](02-funnel-plots.md) - Check for publication bias
- [03-subgroup-plots.md](03-subgroup-plots.md) - Subgroup analysis
- [04-multi-panel.md](04-multi-panel.md) - Combine with other plots
- [07-themes-colors.md](07-themes-colors.md) - Customize colors
