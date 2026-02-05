---
name: ma-data-extraction
description: Define extraction schema, extract study data from full texts, and store it in a structured database for meta-analysis. Use when moving from full-text collection to statistical analysis.
---

# Ma Data Extraction

## Overview
Extract consistent data, capture provenance, and build a clean analysis dataset.

## Inputs
- `04_fulltext/manifest.csv`
- `01_protocol/outcomes.md`

## Outputs
- `05_extraction/extraction.sqlite`
- `05_extraction/extraction.csv`
- `05_extraction/llm_suggestions.jsonl` (optional)
- `05_extraction/data-dictionary.md`
- `05_extraction/extraction-log.md`
- `05_extraction/study_map.csv` (optional if `record_id` not in extraction CSV)
- `05_extraction/source.csv` (optional source references)
- `05_extraction/source_validation.md` (optional)

## Workflow
1. Define a data dictionary that covers outcomes, covariates, and study identifiers.
2. Initialize a normalized SQLite database using `scripts/init_extraction_db.py` via `uv run`.
3. Extract data with double-entry or verification where possible.
4. Optionally run `scripts/llm_extract.py` via `uv run` to generate extraction suggestions for manual review.
5. Record unit conversions and assumptions in `05_extraction/extraction-log.md`.
6. Export a tidy CSV for analysis and lock the database snapshot.
7. (Recommended) Record source references in `05_extraction/source.csv` and validate with `scripts/validate_sources.py`.

## Resources
- `scripts/init_extraction_db.py` initializes a standard extraction schema.
- `scripts/llm_extract.py` provides LLM-assisted extraction suggestions.
- `scripts/validate_sources.py` validates extraction vs source references.
- `references/data-dictionary-template.md` provides a dictionary scaffold.
- `references/study-map-template.csv` maps `record_id` to `study_id` if needed.
- `references/source-template.csv` for source references.
Note: `llm_extract.py` requires a PDF parser such as `pdfplumber` or `pypdf` (install via `uv add`).

## Validation
- Run consistency checks on missingness, ranges, and duplicated entries.
- Reconcile any discrepancies between double entries before analysis.
- Validate source coverage with `scripts/validate_sources.py` when sources are available.
