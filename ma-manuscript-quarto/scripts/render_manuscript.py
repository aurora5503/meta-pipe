#!/usr/bin/env python3
"""Validate pipeline and render Quarto manuscript."""

from __future__ import annotations

import argparse
import csv
import subprocess
import sys
from pathlib import Path


def validate_result_claims(root: Path) -> None:
    claims_path = root / "07_manuscript" / "result_claims.csv"
    if not claims_path.exists():
        raise SystemExit(f"Missing result claims table: {claims_path}")

    with claims_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        rows = [{k: (v or "").strip() for k, v in row.items()} for row in reader]

    if not rows:
        raise SystemExit("result_claims.csv has no rows.")

    missing_refs = []
    missing_files = []
    missing_effect_fields = []
    for idx, row in enumerate(rows, start=1):
        fig = row.get("figure_ref", "")
        tbl = row.get("table_ref", "")
        if not fig and not tbl:
            missing_refs.append(f"row {idx} ({row.get('claim_id', '')})")
            continue

        effect = row.get("effect_estimate", "")
        ci = row.get("ci", "")
        p_value = row.get("p_value", "")
        if not effect or not ci or not p_value:
            missing_effect_fields.append(f"row {idx} ({row.get('claim_id', '')})")

        for ref in [fig, tbl]:
            if not ref:
                continue
            ref_path = Path(ref)
            if not ref_path.is_absolute():
                ref_path = (root / "07_manuscript" / ref_path).resolve()
            if not ref_path.exists():
                missing_files.append(f"{row.get('claim_id', '')}: {ref}")

    if missing_refs:
        raise SystemExit(
            "Result claims missing figure/table refs: " + ", ".join(missing_refs)
        )
    if missing_files:
        raise SystemExit(
            "Result claims reference missing files: " + ", ".join(missing_files)
        )
    if missing_effect_fields:
        raise SystemExit(
            "Result claims missing effect/CI/p-value: " + ", ".join(missing_effect_fields)
        )


def validate_results_in_manuscript(root: Path) -> None:
    claims_path = root / "07_manuscript" / "result_claims.csv"
    results_path = root / "07_manuscript" / "03_results.qmd"
    if not claims_path.exists() or not results_path.exists():
        return

    with claims_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        claims = [{k: (v or "").strip() for k, v in row.items()} for row in reader]

    results_text = results_path.read_text()
    missing_claims = []
    for row in claims:
        claim_id = row.get("claim_id", "")
        if not claim_id:
            continue
        if claim_id not in results_text:
            missing_claims.append(claim_id)

    if missing_claims:
        raise SystemExit(
            "Results missing claim IDs: " + ", ".join(sorted(missing_claims))
        )

    missing_refs = []
    for row in claims:
        ref = row.get("figure_ref", "") or row.get("table_ref", "")
        if ref and ref not in results_text:
            missing_refs.append(ref)
    if missing_refs:
        raise SystemExit(
            "Results missing figure/table references: " + ", ".join(sorted(set(missing_refs)))
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate and render manuscript.")
    parser.add_argument("--root", default=".", help="Project root")
    parser.add_argument("--index", default="07_manuscript/index.qmd", help="Quarto index file")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    repo_root = Path(__file__).resolve().parents[2]

    sys.path.append(str(repo_root / "ma-end-to-end" / "scripts"))
    import validate_pipeline  # type: ignore

    ok, issues = validate_pipeline.validate(root)
    if not ok:
        print("Checklist validation failed. Fix before rendering:")
        for issue in issues:
            print(f"- {issue}")
        raise SystemExit(2)

    validate_result_claims(root)
    validate_results_in_manuscript(root)

    index_path = root / args.index
    if not index_path.exists():
        raise SystemExit(f"Missing index file: {index_path}")

    result = subprocess.run(["quarto", "render", str(index_path)], check=False)
    raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
