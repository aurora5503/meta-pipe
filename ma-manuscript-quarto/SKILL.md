---
name: ma-manuscript-quarto
description: Draft and render a meta-analysis manuscript with Quarto using an IMRaD structure and embedded figures/tables. Use when preparing the final paper from analysis outputs.
---

# Ma Manuscript Quarto

## Overview

Create a Quarto manuscript with standard IMRaD sections and render to PDF and HTML.

## Inputs

- `06_analysis/figures/`
- `06_analysis/tables/`
- `02_search/round-01/dedupe.bib` or final bibliography

## Outputs

- `07_manuscript/00_abstract.qmd`
- `07_manuscript/01_introduction.qmd`
- `07_manuscript/02_methods.qmd`
- `07_manuscript/03_results.qmd`
- `07_manuscript/04_discussion.qmd`
- `07_manuscript/tables.qmd` (standalone PNG table images)
- `07_manuscript/figures_legends.qmd` (figure legends with embedded PNGs)
- `07_manuscript/index.qmd`
- `07_manuscript/Makefile` (sync + render automation)
- `07_manuscript/references.bib`
- `07_manuscript/index.html` (rendered HTML)
- `07_manuscript/index.pdf` (rendered PDF via Typst)
- `07_manuscript/index.docx` (rendered Word with PNG tables)
- `07_manuscript/figures/` (synced from `06_analysis/figures/`)
- `07_manuscript/tables/` (synced PNG + CSV from `06_analysis/tables/`)
- `07_manuscript/prisma_flow.md`
- `07_manuscript/prisma_flow.svg`
- `07_manuscript/evidence_map.md`
- `07_manuscript/result_claims.csv`
- `07_manuscript/result_paragraphs.md`
- `07_manuscript/result_paragraphs.qmd`
- `07_manuscript/result_summary_table.md` (auto-inserted into Results)
- `07_manuscript/traceability_table.md`
- `07_manuscript/study_characteristics.md`
- `07_manuscript/study_characteristics.csv`
- `07_manuscript/submission_checklist.md`
- `07_manuscript/03_results.qmd` (assembled)
- `09_qa/results_consistency_report.md`

## Workflow

1. Initialize a Quarto project in `07_manuscript/`.
2. Copy Quarto templates from `assets/quarto/` and adapt to the project.
3. Embed figures and tables with captions and cross-references.
4. Include PRISMA-style reporting elements and a flow diagram when applicable.
5. Generate the PRISMA flow summary with `scripts/prisma_flow.py` via `uv run`, optionally writing an SVG. Use `--strict` for final renders.
6. Insert the search report and audit hashes into Methods with `scripts/insert_search_report.py`.
7. Build a manuscript evidence map with `scripts/build_evidence_map.py` and review key results before writing.
8. Initialize `result_claims.csv` with `scripts/init_result_claims.py` and draft Results from it.
9. Generate Results paragraph stubs with `scripts/build_result_paragraphs.py`.
10. Build study characteristics table with `scripts/build_study_characteristics.py`.
11. Insert the traceability table into Methods with `scripts/insert_traceability_table.py`.
12. Assemble Results into `03_results.qmd` with `scripts/assemble_results.py` (also inserts `result_summary_table.md`).
13. Populate the bibliography and ensure citation keys match.
14. Generate a results consistency report with `scripts/results_consistency_report.py`.
15. Initialize the submission checklist with `scripts/init_submission_checklist.py`.
16. Use Makefile `sync` target to copy figures and tables from `06_analysis/` (see Build & Sync below).
17. Render to HTML, PDF, and DOCX with `make all` or individual targets.

## Build & Sync Workflow

The manuscript uses a **Makefile** to automate syncing analysis outputs and rendering.

### Why Sync?

Analysis scripts in `06_analysis/` produce figures (PNG) and tables (PNG + CSV + HTML + DOCX via `gt`/`flextable`). The manuscript in `07_manuscript/` references local copies so Quarto can embed them. The `sync` step copies the latest outputs before every render, ensuring the manuscript always reflects current analysis.

### Makefile

```makefile
.PHONY: all html pdf docx clean sync

ANALYSIS_DIR := ../06_analysis

all: sync html pdf docx

sync:
	@mkdir -p figures tables
	@cp -f $(ANALYSIS_DIR)/figures/*.png figures/
	@cp -f $(ANALYSIS_DIR)/tables/*.png tables/
	@cp -f $(ANALYSIS_DIR)/tables/*.csv tables/

html: sync
	quarto render index.qmd --to html

pdf: sync
	quarto render index.qmd --to typst

docx: sync
	quarto render index.qmd --to docx

clean:
	command rip -f index.html index.pdf index.docx index_files/
```

### Usage

```bash
cd projects/<project>/07_manuscript

make sync     # Copy latest figures + tables from 06_analysis
make docx     # Sync + render Word (tables as PNG images)
make html     # Sync + render self-contained HTML
make pdf      # Sync + render PDF via Typst
make          # Sync + render all formats
```

### What Gets Synced

| Source (`06_analysis/`) | Destination (`07_manuscript/`) | Used By               |
| ----------------------- | ------------------------------ | --------------------- |
| `figures/*.png`         | `figures/`                     | `figures_legends.qmd` |
| `tables/*.png`          | `tables/`                      | `tables.qmd`          |
| `tables/*.csv`          | `tables/`                      | Reference data        |

### Sync Direction

**One-way**: `06_analysis → 07_manuscript`. Never edit PNGs in `07_manuscript/` directly; regenerate from R scripts in `06_analysis/` and re-run `make sync`.

## Tables as Standalone PNG Images

Tables are generated in R (via `gt` + `flextable` in `07_export_tables.R`) and exported as PNG, HTML, and DOCX. The manuscript embeds the **PNG images** directly.

### Why PNG Tables?

1. **Consistent rendering** across HTML, PDF, and DOCX outputs
2. **Publication-quality formatting** via `gt` package (colors, bold, footnotes)
3. **No Quarto table rendering issues** (complex tables with merged cells, conditional formatting)
4. **Single source of truth**: R script generates all formats; manuscript just references PNGs

### Table Export Script (`06_analysis/07_export_tables.R`)

The R script exports each table in 3 formats:

```r
library(gt)
library(flextable)

export_table <- function(gt_tbl, ft_tbl, basename, vwidth = 800) {
  gt_tbl %>% gtsave(paste0("tables/", basename, ".html"))
  gt_tbl %>% gtsave(paste0("tables/", basename, ".png"), vwidth = vwidth)
  save_as_docx(ft_tbl, path = paste0("tables/", basename, ".docx"))
}
```

### `tables.qmd` Structure

```markdown
# Tables

## Table 1. Trial Characteristics {#tbl-characteristics}

![](tables/table1_characteristics.png){width=100%}

---

## Table 2. Risk of Bias {#tbl-rob2}

![](tables/table2_rob2.png){width=100%}
```

Each table is a heading + standalone PNG image. The `{width=100%}` ensures proper scaling across formats.

### Output Formats

| Format | Table Rendering | Notes                                       |
| ------ | --------------- | ------------------------------------------- |
| HTML   | Embedded PNG    | Self-contained, sharp on retina             |
| PDF    | Embedded PNG    | Via Typst, respects width                   |
| DOCX   | Embedded PNG    | Word embeds image inline; no editable cells |

## Output Formats

The `index.qmd` YAML configures three output formats:

```yaml
format:
  html:
    toc: true
    toc-depth: 3
    number-sections: true
    embed-resources: true
  docx:
    toc: true
    number-sections: true
  typst:
    toc: true
    number-sections: true
    columns: 1
    margin:
      x: 1in
      y: 1in
    papersize: us-letter
    mainfont: "New Computer Modern"
    fontsize: 11pt
```

- **HTML**: Self-contained (`embed-resources: true`), good for review and sharing
- **DOCX**: Word format for journal submission and co-author editing; tables render as PNG images
- **PDF**: Via Typst engine (faster than LaTeX, good typography)

## Discussion Guidance

- Interpret the main effect estimates and clinical or practical significance.
- Discuss heterogeneity, sensitivity analyses, and publication bias.
- Compare findings to prior reviews and explain divergences.
- State limitations, generalizability, and future research needs.

## Quarto Syntax Reference

See `references/quarto-syntax-guide.md` for the complete reference covering:

- `_quarto.yml` project configuration (`type: manuscript`)
- Cross-references: `{#fig-label}`, `{#tbl-label}`, `{#sec-label}`, `{#eq-label}`
- Figures with alt-text, sizing, subfigures (`layout-ncol`)
- Tables (pipe and grid), subtables, caption placement
- Citations: `[@key]` parenthetical, `@key` in-text, `[-@key]` suppress author
- Includes: `{{< include file.qmd >}}`, page breaks: `{{< pagebreak >}}`
- PDF options, journal extensions, callouts

**Key rules**: labels must be lowercase, use hyphens (not underscores), and always include the prefix.

## QMD Linter & Formatter

Run `scripts/lint_qmd.py` to validate manuscript files against Quarto best practices:

```bash
# Report only
uv run ma-manuscript-quarto/scripts/lint_qmd.py \
  --dir projects/<project>/07_manuscript/

# Auto-fix + report
uv run ma-manuscript-quarto/scripts/lint_qmd.py \
  --dir projects/<project>/07_manuscript/ \
  --fix --out-md /tmp/lint_report.md
```

**Checks** (15 rules, L001-L015):

| Severity | Rules                                                                                                                                           |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| error    | L001 underscore in labels, L002 uppercase labels, L011 missing YAML, L012 missing bib, L013 missing include                                     |
| warning  | L003 figure no label, L004 table no label, L005 footnote numbers, L006 \\newpage, L007 bare URL, L010 skipped heading, L014 missing figure file |
| style    | L008 trailing whitespace, L009 no blank before heading, L015 double blank lines                                                                 |

**Auto-fixable**: L006, L008, L009, L015. Exit codes: 0 clean, 1 warnings, 2 errors.

## Resources

- `assets/quarto/` provides an IMRaD Quarto scaffold.
- `references/quarto-syntax-guide.md` — Quarto syntax reference for meta-analysis manuscripts.
- `scripts/lint_qmd.py` validates and auto-fixes QMD/MD files against Quarto best practices.
- `scripts/prisma_flow.py` generates a PRISMA flow diagram summary and optional SVG.
- `scripts/insert_search_report.py` injects search report content into Methods.
- `scripts/build_evidence_map.py` creates a checklist of outputs to base writing on.
- `scripts/init_result_claims.py` seeds a results-to-evidence table for drafting.
- `scripts/build_result_paragraphs.py` creates paragraph stubs and a summary table for Results writing.
- `scripts/build_study_characteristics.py` generates the study characteristics table from extraction.
- `scripts/insert_traceability_table.py` inserts a protocol→search→screening→inclusion table into Methods.
- The traceability narrative is auto-inserted into `02_methods.qmd` near Study Selection.
- `scripts/assemble_results.py` injects result paragraphs into `03_results.qmd`.
- `scripts/results_consistency_report.py` checks claim/output/citation consistency.
- `scripts/init_submission_checklist.py` seeds a journal submission checklist.
- `scripts/render_manuscript.py` validates checklists before rendering.

## Validation

- Run `scripts/lint_qmd.py --dir 07_manuscript/` — must pass with exit code 0 (no errors).
- Ensure all figures are 300 dpi and tables are reproducible.
- Cross-check that every result in the text appears in the analysis outputs.
- Review `07_manuscript/evidence_map.md` before drafting Results.
- Ensure each results paragraph maps to `07_manuscript/result_claims.csv`.
- Verify `07_manuscript/traceability_table.md` is inserted into `02_methods.qmd`.
- Ensure each claim includes effect estimate, confidence interval, and p-value.
- Ensure `03_results.qmd` contains all claim IDs and their figure/table refs.
- Ensure `09_qa/results_consistency_report.md` has no missing items.
- Ensure each claim includes `citation_keys` and the citations appear in Results.
  Note: `citation_keys` should be comma-separated BibTeX keys present in `07_manuscript/references.bib`.
- Note: set `RESULTS_MIN_WORDS` to control minimum words per claim paragraph (default 25).
- Ensure the study characteristics table is inserted into `03_results.qmd`.
- Ensure `submission_checklist.md` is tailored to the target journal.

## Pipeline Navigation

| Step | Skill               | Stage                       |
| ---- | ------------------- | --------------------------- |
| Prev | `/ma-meta-analysis` | 06 Statistical Analysis     |
| Next | `/ma-peer-review`   | 08 Peer Review & GRADE      |
| All  | `/ma-end-to-end`    | Full pipeline orchestration |
