#!/usr/bin/env Rscript
# Test R scripts for meta-analysis pipeline
#
# Usage:
#   cd /Users/htlin/meta-pipe
#   Rscript tests/test_r_scripts.R

# Get script directory
args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("--file=", "", args[grep("--file=", args)])
if (length(script_path) == 0) {
  # Running interactively or sourced
  script_path <- "tests/test_r_scripts.R"
}

# Paths
ROOT <- normalizePath(dirname(dirname(script_path)))
FIXTURES <- file.path(ROOT, "tests", "fixtures")
SCRIPTS <- file.path(ROOT, "ma-meta-analysis", "assets", "r")

cat("\n")
cat("==================================================\n")
cat("R SCRIPT TESTS\n")
cat("==================================================\n")
cat("ROOT:", ROOT, "\n")
cat("FIXTURES:", FIXTURES, "\n")

# Track test results
tests_passed <- 0
tests_failed <- 0

run_test <- function(name, test_fn) {
  cat("\n[TEST]", name, "\n")
  tryCatch({
    result <- test_fn()
    if (isTRUE(result)) {
      cat("  ✅ PASSED\n")
      tests_passed <<- tests_passed + 1
    } else {
      cat("  ❌ FAILED:", result, "\n")
      tests_failed <<- tests_failed + 1
    }
  }, error = function(e) {
    cat("  ❌ ERROR:", conditionMessage(e), "\n")
    tests_failed <<- tests_failed + 1
  })
}

# =============================================================================
# Test 1: Check required packages
# =============================================================================
run_test("Required packages available", function() {
  required_pkgs <- c("dplyr", "readr", "metafor")
  missing <- c()

  for (pkg in required_pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing <- c(missing, pkg)
    }
  }

  if (length(missing) > 0) {
    return(paste("Missing:", paste(missing, collapse = ", ")))
  }
  cat("  All packages available:", paste(required_pkgs, collapse = ", "), "\n")
  TRUE
})

# =============================================================================
# Test 2: Load test extraction data
# =============================================================================
run_test("Load extraction data", function() {
  extraction_file <- file.path(FIXTURES, "05_extraction", "extraction.csv")

  if (!file.exists(extraction_file)) {
    return(paste("File not found:", extraction_file))
  }

  raw <- readr::read_csv(extraction_file, show_col_types = FALSE)
  cat("  Rows:", nrow(raw), "\n")
  cat("  Studies:", length(unique(raw$study_id)), "\n")

  # Check required columns
  required_cols <- c("study_id", "outcome_id", "outcome_type", "n", "mean", "sd", "events", "total")
  missing_cols <- setdiff(required_cols, names(raw))

  if (length(missing_cols) > 0) {
    return(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
  }

  if (nrow(raw) == 0) {
    return("No data rows")
  }

  TRUE
})

# =============================================================================
# Test 3: Effect size calculation (continuous)
# =============================================================================
run_test("Effect size calculation (continuous)", function() {
  library(dplyr, warn.conflicts = FALSE)
  library(metafor, quietly = TRUE)

  extraction_file <- file.path(FIXTURES, "05_extraction", "extraction.csv")
  raw <- readr::read_csv(extraction_file, show_col_types = FALSE)

  continuous <- raw %>%
    filter(outcome_type == "continuous") %>%
    group_by(study_id, outcome_id) %>%
    mutate(arm_order = row_number()) %>%
    filter(n() == 2) %>%
    arrange(study_id, outcome_id, arm_order) %>%
    ungroup()

  if (nrow(continuous) == 0) {
    return("No continuous outcome pairs")
  }

  arm1 <- continuous %>% filter(arm_order == 1)
  arm2 <- continuous %>% filter(arm_order == 2)

  cont_es <- escalc(
    measure = "SMD",
    m1i = arm1$mean, sd1i = arm1$sd, n1i = arm1$n,
    m2i = arm2$mean, sd2i = arm2$sd, n2i = arm2$n,
    slab = arm1$study_id
  )

  cat("  Effect sizes:", nrow(cont_es), "\n")
  cat("  SMD range: [", round(min(cont_es$yi), 2), ",", round(max(cont_es$yi), 2), "]\n")

  if (any(is.na(cont_es$yi))) {
    return("Some effect sizes are NA")
  }

  TRUE
})

# =============================================================================
# Test 4: Effect size calculation (binary)
# =============================================================================
run_test("Effect size calculation (binary)", function() {
  library(dplyr, warn.conflicts = FALSE)
  library(metafor, quietly = TRUE)

  extraction_file <- file.path(FIXTURES, "05_extraction", "extraction.csv")
  raw <- readr::read_csv(extraction_file, show_col_types = FALSE)

  binary <- raw %>%
    filter(outcome_type == "binary") %>%
    group_by(study_id, outcome_id) %>%
    mutate(arm_order = row_number()) %>%
    filter(n() == 2) %>%
    arrange(study_id, outcome_id, arm_order) %>%
    ungroup()

  if (nrow(binary) == 0) {
    return("No binary outcome pairs")
  }

  arm1 <- binary %>% filter(arm_order == 1)
  arm2 <- binary %>% filter(arm_order == 2)

  bin_es <- escalc(
    measure = "RR",
    ai = arm1$events, n1i = arm1$total,
    ci = arm2$events, n2i = arm2$total,
    slab = arm1$study_id
  )

  cat("  Effect sizes:", nrow(bin_es), "\n")
  cat("  log(RR) range: [", round(min(bin_es$yi), 2), ",", round(max(bin_es$yi), 2), "]\n")

  if (any(is.na(bin_es$yi))) {
    return("Some effect sizes are NA")
  }

  TRUE
})

# =============================================================================
# Test 5: Random-effects meta-analysis
# =============================================================================
run_test("Random-effects meta-analysis", function() {
  library(dplyr, warn.conflicts = FALSE)
  library(metafor, quietly = TRUE)

  extraction_file <- file.path(FIXTURES, "05_extraction", "extraction.csv")
  raw <- readr::read_csv(extraction_file, show_col_types = FALSE)

  # Use HDRS (O1) outcome
  continuous <- raw %>%
    filter(outcome_type == "continuous", outcome_id == "O1") %>%
    group_by(study_id) %>%
    mutate(arm_order = row_number()) %>%
    filter(n() == 2) %>%
    arrange(study_id, arm_order) %>%
    ungroup()

  arm1 <- continuous %>% filter(arm_order == 1)
  arm2 <- continuous %>% filter(arm_order == 2)

  cont_es <- escalc(
    measure = "SMD",
    m1i = arm1$mean, sd1i = arm1$sd, n1i = arm1$n,
    m2i = arm2$mean, sd2i = arm2$sd, n2i = arm2$n,
    slab = arm1$study_id
  )

  # Fit model
  model <- rma(yi, vi, data = cont_es, method = "REML")

  cat("  Studies: k =", model$k, "\n")
  cat("  Pooled SMD:", round(model$beta[1], 3), "\n")
  cat("  95% CI: [", round(model$ci.lb, 3), ",", round(model$ci.ub, 3), "]\n")
  cat("  I²:", round(model$I2, 1), "%\n")
  cat("  p-value:", format.pval(model$pval, digits = 3), "\n")

  if (model$k < 2) {
    return("Need at least 2 studies")
  }

  TRUE
})

# =============================================================================
# Test 6: Forest plot generation
# =============================================================================
run_test("Forest plot generation", function() {
  library(dplyr, warn.conflicts = FALSE)
  library(metafor, quietly = TRUE)

  extraction_file <- file.path(FIXTURES, "05_extraction", "extraction.csv")
  raw <- readr::read_csv(extraction_file, show_col_types = FALSE)

  continuous <- raw %>%
    filter(outcome_type == "continuous", outcome_id == "O1") %>%
    group_by(study_id) %>%
    mutate(arm_order = row_number()) %>%
    filter(n() == 2) %>%
    arrange(study_id, arm_order) %>%
    ungroup()

  arm1 <- continuous %>% filter(arm_order == 1)
  arm2 <- continuous %>% filter(arm_order == 2)

  cont_es <- escalc(
    measure = "SMD",
    m1i = arm1$mean, sd1i = arm1$sd, n1i = arm1$n,
    m2i = arm2$mean, sd2i = arm2$sd, n2i = arm2$n,
    slab = arm1$study_id
  )

  model <- rma(yi, vi, data = cont_es, method = "REML")

  # Generate forest plot
  tmp_file <- tempfile(fileext = ".png")
  png(tmp_file, width = 800, height = 600)
  forest(model, xlab = "Standardized Mean Difference")
  dev.off()

  if (!file.exists(tmp_file)) {
    return("Forest plot file not created")
  }

  file_size <- file.info(tmp_file)$size
  cat("  File size:", file_size, "bytes\n")

  unlink(tmp_file)

  if (file_size < 1000) {
    return("Forest plot file too small")
  }

  TRUE
})

# =============================================================================
# Summary
# =============================================================================
cat("\n")
cat("==================================================\n")
cat("SUMMARY\n")
cat("==================================================\n")
cat("  ✅ Passed:", tests_passed, "\n")
cat("  ❌ Failed:", tests_failed, "\n")
cat("\n")

if (tests_failed > 0) {
  cat("❌ Some tests failed\n")
  quit(status = 1)
} else {
  cat("✅ All R tests passed\n")
  quit(status = 0)
}
