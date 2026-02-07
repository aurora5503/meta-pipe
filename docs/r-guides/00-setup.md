# R Package Setup for Meta-Analysis

**When to use**: First time setting up R for meta-analysis
**Time**: 10-15 minutes
**Prerequisite**: R and RStudio installed

---

## Quick Install (Copy & Paste)

```r
# Core meta-analysis packages
install.packages(c("meta", "metafor", "dmetar"))

# Visualization
install.packages(c("ggplot2", "patchwork", "cowplot"))

# Tables
install.packages(c("gtsummary", "gt", "flextable", "kableExtra"))

# Themes & Colors
install.packages(c("hrbrthemes", "ggsci", "viridis", "ggthemes"))

# Data manipulation
install.packages(c("tidyverse"))
```

**Total time**: ~5-10 minutes depending on internet speed

---

## What Each Package Does

### Meta-Analysis Core

```r
install.packages(c("meta", "metafor", "dmetar"))
```

- **meta**: Simple interface for meta-analysis (recommended for beginners)
  - [CRAN](https://cran.r-project.org/web/packages/meta/)
  - Use for: forest plots, funnel plots, basic meta-analysis

- **metafor**: Advanced meta-analysis toolkit
  - [Website](https://www.metafor-project.org/)
  - Use for: complex models, meta-regression, advanced diagnostics

- **dmetar**: Companion to "Doing Meta-Analysis in R" book
  - [Website](https://dmetar.protectlab.org/)
  - Use for: helper functions, tutorials

### Visualization

```r
install.packages(c("ggplot2", "patchwork", "cowplot"))
```

- **ggplot2**: Grammar of graphics
  - [Website](https://ggplot2.tidyverse.org/)
  - Use for: all custom plots

- **patchwork**: Combine multiple plots
  - [Website](https://patchwork.data-imaginist.com/)
  - Use for: multi-panel figures (`p1 / p2 / p3`)

- **cowplot**: Publication-ready plot layouts
  - [Website](https://wilkelab.org/cowplot/)
  - Use for: precise control over panel arrangement

### Tables

```r
install.packages(c("gtsummary", "gt", "flextable"))
```

- **gtsummary**: Summary tables with statistics
  - [Website](https://www.danieldsjoberg.com/gtsummary/)
  - Use for: Table 1, regression tables

- **gt**: Grammar of tables (for HTML/PDF)
  - [Website](https://gt.rstudio.com/)
  - Use for: export gtsummary to HTML

- **flextable**: Tables for Word/PowerPoint
  - [Website](https://ardata-fr.github.io/flextable-book/)
  - Use for: export gtsummary to DOCX

### Themes & Colors

```r
install.packages(c("hrbrthemes", "ggsci", "viridis"))
```

- **hrbrthemes**: Professional typography
  - [CRAN](https://cran.r-project.org/web/packages/hrbrthemes/)
  - Use for: clean, readable plots

- **ggsci**: Scientific journal color palettes
  - [CRAN](https://cran.r-project.org/web/packages/ggsci/)
  - Use for: Lancet, NEJM, Nature colors

- **viridis**: Colorblind-safe palettes
  - [CRAN](https://cran.r-project.org/web/packages/viridis/)
  - Use for: heatmaps, continuous scales

---

## Verify Installation

```r
# Test that packages loaded successfully
library(meta)
library(ggplot2)
library(gtsummary)
library(patchwork)

# If no errors, you're ready to go!
cat("✅ All packages installed successfully!\n")
```

---

## Optional: GitHub Packages

Some packages require installation from GitHub:

```r
# Install devtools first
install.packages("devtools")

# ggthemr - easy theme switching
devtools::install_github("Mikata-Project/ggthemr")
```

---

## Troubleshooting

### Problem: Package installation fails

```r
# Try changing CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))
install.packages("meta")
```

### Problem: "non-zero exit status"

**Solution**: Install system dependencies first (macOS)

```bash
# In Terminal, not R
brew install cairo
brew install harfbuzz
brew install fribidi
```

**Solution**: Install system dependencies (Ubuntu/Debian)

```bash
sudo apt-get install libcairo2-dev
sudo apt-get install libharfbuzz-dev
sudo apt-get install libfribidi-dev
```

---

## See Also

- [01-forest-plots.md](01-forest-plots.md) - Start making forest plots
- [05-table1-gtsummary.md](05-table1-gtsummary.md) - Create Table 1
- [07-themes-colors.md](07-themes-colors.md) - Choose colors and themes
