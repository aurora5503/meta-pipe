# Agent Instructions

AI-assisted meta-analysis pipeline. This file is auto-loaded by Claude Code.

## When User Says "Start" or "See TOPIC.txt"

1. **Read `TOPIC.txt`** to understand the research question
2. **Check project state** - which stages are complete?
3. **Ask only essential questions** before proceeding:
   - Databases to search (PubMed, Scopus, Embase, Cochrane?)
   - Date range limits?
   - Language restrictions?
   - Study design (RCTs only, or include observational?)
4. **Initialize project** if not done:
   ```bash
   cd /Users/htlin/meta-pipe/tooling/python
   uv run ../../ma-end-to-end/scripts/init_project.py --root ../..
   ```
5. **Execute pipeline stages** in order, validating at each step

## Resume Behavior

If user says "continue", "what's next", or "status":
1. Check which stage folders have content
2. Report current progress
3. Suggest next action

## Rules

- **Python**: Always `uv run`, never `python3` directly
- **Dependencies**: `uv add <package>`
- **API keys**: Read from `.env` ([docs/API_SETUP.md](docs/API_SETUP.md))
- **Rounds**: Keep all `round-XX` data, never overwrite
- **Delete**: Use `rip` not `rm`

## Pipeline Stages

| Stage | Folder | Key Output | Validation |
|-------|--------|------------|------------|
| 01 | `01_protocol/` | pico.yaml, eligibility.md | PICO complete |
| 02 | `02_search/` | dedupe.bib | Records > 0 |
| 03 | `03_screening/` | decisions.csv | Kappa ≥ 0.60 |
| 04 | `04_fulltext/` | manifest.csv | PDFs collected |
| 05 | `05_extraction/` | extraction.csv | No missing study_id |
| 06 | `06_analysis/` | figures/, tables/ | R scripts 01-09 |
| 07 | `07_manuscript/` | manuscript.pdf | PRISMA complete |
| 08 | `08_reviews/` | grade_summary.md | GRADE filled |
| 09 | `09_qa/` | final_qa_report.md | All checks pass |

## Decision Points (Ask User)

Only ask if information is missing from TOPIC.txt:
- Target population, intervention, comparator, outcomes (PICO)
- Which databases to search
- Risk-of-bias tool (RoB 2 vs ROBINS-I)
- Effect measure (RR/OR/HR/SMD/MD)
- Subgroup variables

## Commands Reference

<details>
<summary><strong>Stage 02: Search</strong></summary>

```bash
cd /Users/htlin/meta-pipe/tooling/python

# Build queries from PICO
uv run ../../ma-search-bibliography/scripts/build_queries.py \
  --pico ../../01_protocol/pico.yaml \
  --out ../../02_search/round-01/queries.txt

# PubMed search
uv add biopython requests bibtexparser pyyaml
uv run ../../ma-search-bibliography/scripts/pubmed_fetch.py \
  --query "<query>" --email "you@example.com" \
  --out-bib ../../02_search/round-01/results.bib \
  --out-log ../../02_search/round-01/log.md

# Multi-DB (all at once)
uv run ../../ma-search-bibliography/scripts/run_multi_db_search.py \
  --root ../.. --round round-01 --email "you@example.com"

# Dedupe
uv run ../../ma-search-bibliography/scripts/dedupe_bib.py \
  --in-bib ../../02_search/round-01/results.bib \
  --out-bib ../../02_search/round-01/dedupe.bib \
  --out-log ../../02_search/round-01/dedupe.log
```
</details>

<details>
<summary><strong>Stage 03: Screening</strong></summary>

Required CSV columns: `record_id, title, decision_r1, decision_r2, final_decision, exclusion_reason`

```bash
uv run ../../ma-screening-quality/scripts/dual_review_agreement.py \
  --file ../../03_screening/round-01/decisions.csv \
  --col-a decision_r1 --col-b decision_r2 \
  --out ../../03_screening/round-01/agreement.md
```
</details>

<details>
<summary><strong>Stage 04: Fulltext</strong></summary>

```bash
uv run ../../ma-fulltext-management/scripts/unpaywall_fetch.py \
  --in-bib ../../03_screening/round-01/included.bib \
  --out-csv ../../04_fulltext/unpaywall_results.csv
```
</details>

<details>
<summary><strong>Stage 05: Extraction</strong></summary>

```bash
uv add pdfplumber
uv run ../../ma-data-extraction/scripts/llm_extract.py \
  --manifest ../../04_fulltext/manifest.csv \
  --data-dictionary ../../05_extraction/data-dictionary.md \
  --out-jsonl ../../05_extraction/llm_suggestions.jsonl
```
</details>

<details>
<summary><strong>Stage 06: Analysis (R)</strong></summary>

Run in order from `06_analysis/`:
```
01_setup.R → 02_effect_sizes.R → 03_models.R → 04_subgroups_meta_regression.R
→ 05_plots.R → 06_tables.R → 07_sensitivity.R → 08_bias.R → 09_validation.R
```
</details>

<details>
<summary><strong>Stage 07: Manuscript</strong></summary>

```bash
# PRISMA flow
uv run ../../ma-manuscript-quarto/scripts/prisma_flow.py \
  --root ../.. --round round-01 --decisions-column final_decision \
  --out ../../07_manuscript/prisma_flow.md \
  --out-svg ../../07_manuscript/prisma_flow.svg

# Evidence map (verify what exists before writing Results)
uv run ../../ma-manuscript-quarto/scripts/build_evidence_map.py \
  --root ../.. --round round-01 \
  --out 07_manuscript/evidence_map.md

# Result claims table
uv run ../../ma-manuscript-quarto/scripts/init_result_claims.py \
  --root ../.. --out 07_manuscript/result_claims.csv

# Generate result paragraphs
uv run ../../ma-manuscript-quarto/scripts/build_result_paragraphs.py \
  --claims 07_manuscript/result_claims.csv \
  --out 07_manuscript/result_paragraphs.md

# Assemble Results into 03_results.qmd
uv run ../../ma-manuscript-quarto/scripts/assemble_results.py \
  --results 07_manuscript/03_results.qmd \
  --paragraphs 07_manuscript/result_paragraphs.qmd

# Render
uv run ../../ma-manuscript-quarto/scripts/render_manuscript.py \
  --root ../.. --index 07_manuscript/index.qmd
```
</details>

<details>
<summary><strong>Stage 08: GRADE</strong></summary>

```bash
uv run ../../ma-peer-review/scripts/init_grade_summary.py \
  --extraction ../../05_extraction/extraction.csv \
  --out-csv ../../08_reviews/grade_summary.csv \
  --out-md ../../08_reviews/grade_summary.md

uv run ../../ma-peer-review/scripts/auto_grade_suggestion.py \
  --grade ../../08_reviews/grade_summary.csv \
  --out-csv ../../08_reviews/grade_suggestions.csv
```
</details>

<details>
<summary><strong>Stage 09: QA</strong></summary>

```bash
uv run ../../ma-end-to-end/scripts/final_qa_report.py \
  --root ../.. --round round-01 \
  --out 09_qa/final_qa_report.md --out-json 09_qa/final_qa_report.json

# Publication quality checks
uv run ../../ma-publication-quality/scripts/claim_audit.py \
  --abstract ../../07_manuscript/00_abstract.qmd \
  --results ../../07_manuscript/03_results.qmd \
  --out ../../09_qa/claim_audit.md
```
</details>

<details>
<summary><strong>Checkpoints</strong></summary>

```bash
# Create checkpoint before risky operations
uv run ../../ma-end-to-end/scripts/checkpoint.py --create --name pre-analysis

# List checkpoints
uv run ../../ma-end-to-end/scripts/checkpoint.py --list

# Restore (requires --yes)
uv run ../../ma-end-to-end/scripts/checkpoint.py --restore --name pre-analysis --yes
```
</details>

## QA Thresholds

| Check | Threshold | Action if Failed |
|-------|-----------|------------------|
| Dual-review kappa | ≥ 0.60 | Flag, require reconciliation |
| Missing study_id | 0 | Block extraction |
| Numeric fields | ≥ 0 | Block analysis |
| PRISMA NA counts | 0 | Reconcile before render |
| Result-to-table mapping | 100% | Block manuscript |

## Documentation

- **Step-by-step**: [GETTING_STARTED.md](GETTING_STARTED.md)
- **API keys**: [docs/API_SETUP.md](docs/API_SETUP.md)
- **Templates**: Each `ma-*/references/` folder
