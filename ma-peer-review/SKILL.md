---
name: ma-peer-review
description: Act as Reviewer 1 and Reviewer 2 for a meta-analysis manuscript, checking rigor, reproducibility, and reporting compliance. Use when validating the final paper before submission.
---

# Ma Peer Review

## Overview
Perform structured peer review and produce actionable feedback and validation checks.

## Inputs
- `07_manuscript/` rendered outputs
- `06_analysis/validation.md`
- `01_protocol/` and `03_screening/` artifacts

## Outputs
- `08_reviews/reviewer1.md`
- `08_reviews/reviewer2.md`
- `08_reviews/action-items.md`
- `08_reviews/grade_summary.csv`
- `08_reviews/grade_summary.md`
- `08_reviews/grade_suggestions.csv` (optional)
- `08_reviews/grade_suggestions.md` (optional)

## Workflow
1. Reviewer 1 focuses on methodology, inclusion criteria, and statistical validity.
2. Reviewer 2 focuses on clarity, reporting completeness, and reproducibility.
3. Record issues with severity, location, and recommended fixes.
4. Create a consolidated action list with owners and status.
5. Initialize GRADE summary tables with `scripts/init_grade_summary.py` via `uv run`.
6. Optionally generate preliminary GRADE suggestions with `scripts/auto_grade_suggestion.py`.

## Resources
- `references/reporting-checks.md` for PRISMA-style reporting checks.
- `references/grade-template.md` for GRADE evidence profiling.
- `references/grade-summary-schema.md` for GRADE summary columns.
- `scripts/init_grade_summary.py` for generating GRADE summary tables.
- `scripts/auto_grade_suggestion.py` for initial certainty suggestions.

## Validation
- Verify that methods and results are consistent with the protocol.
- Confirm that all outputs are reproducible from the stored data and scripts.
