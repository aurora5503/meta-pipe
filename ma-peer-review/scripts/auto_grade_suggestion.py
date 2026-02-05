#!/usr/bin/env python3
"""Generate preliminary GRADE certainty suggestions."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Dict, List, Tuple


DOMAIN_COLUMNS = [
    "risk_of_bias",
    "inconsistency",
    "indirectness",
    "imprecision",
    "publication_bias",
]


def parse_level(value: str) -> int:
    text = value.strip().lower()
    if not text:
        return 0
    if "very serious" in text or "critical" in text:
        return -2
    if "serious" in text or "high" in text:
        return -1
    return 0


def parse_upgrade(value: str) -> int:
    text = value.strip().lower()
    if not text:
        return 0
    if "very large" in text:
        return 2
    if "large" in text or "dose" in text or "confounding" in text:
        return 1
    if text in {"yes", "y", "true"}:
        return 1
    return 0


def start_level(row: Dict[str, str], default_start: str) -> int:
    start_map = {"high": 4, "moderate": 3, "low": 2, "very low": 1}
    design = ""
    for key in ("design", "study_design", "study_type"):
        if key in row and row[key]:
            design = row[key].lower()
            break
    if "random" in design or "rct" in design:
        return 4
    if "observational" in design or "cohort" in design or "case-control" in design:
        return 2
    return start_map.get(default_start, 3)


def level_to_label(level: int) -> str:
    return {4: "High", 3: "Moderate", 2: "Low", 1: "Very Low"}.get(level, "Moderate")


def suggest(row: Dict[str, str], default_start: str) -> Tuple[str, str]:
    level = start_level(row, default_start)
    downgrades = 0
    upgrade = 0
    reasons = []

    for col in DOMAIN_COLUMNS:
        val = row.get(col, "")
        delta = parse_level(val)
        if delta:
            downgrades += -delta
            reasons.append(f"{col}: {val}")

    for key in ("upgrade", "large_effect", "dose_response", "residual_confounding"):
        if key in row and row[key]:
            delta = parse_upgrade(row[key])
            if delta:
                upgrade += delta
                reasons.append(f"{key}: {row[key]}")

    level = max(1, min(4, level - downgrades + upgrade))
    label = level_to_label(level)
    note = f"Auto-suggested: start={level_to_label(start_level(row, default_start))}"
    if reasons:
        note += f"; reasons: {', '.join(reasons)}"
    return label, note


def read_csv(path: Path) -> Tuple[List[str], List[Dict[str, str]]]:
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        rows = [{k: (v or "").strip() for k, v in row.items()} for row in reader]
        return (reader.fieldnames or [], rows)


def write_csv(path: Path, headers: List[str], rows: List[Dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)


def write_md(path: Path, headers: List[str], rows: List[Dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = ["# GRADE Auto-Suggestions", ""]
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
    for row in rows:
        line = "| " + " | ".join(row.get(h, "") for h in headers) + " |"
        lines.append(line)
    path.write_text("\n".join(lines) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate preliminary GRADE certainty suggestions.")
    parser.add_argument("--grade", required=True, help="Input grade_summary.csv")
    parser.add_argument("--out-csv", required=True, help="Output CSV with suggestions")
    parser.add_argument("--out-md", required=True, help="Output markdown with suggestions")
    parser.add_argument(
        "--default-start",
        default="moderate",
        choices=["high", "moderate", "low", "very low"],
        help="Starting certainty if design missing",
    )
    args = parser.parse_args()

    headers, rows = read_csv(Path(args.grade))
    if not rows:
        raise SystemExit("No rows found in grade summary.")

    out_headers = headers + ["suggested_certainty", "suggested_notes"]
    out_rows = []
    for row in rows:
        suggestion, notes = suggest(row, args.default_start)
        row_out = dict(row)
        row_out["suggested_certainty"] = suggestion
        row_out["suggested_notes"] = notes
        out_rows.append(row_out)

    write_csv(Path(args.out_csv), out_headers, out_rows)
    write_md(Path(args.out_md), out_headers, out_rows)


if __name__ == "__main__":
    main()
