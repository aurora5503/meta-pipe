#!/usr/bin/env python3
"""Initialize a numbered meta-analysis project tree."""

from __future__ import annotations

import argparse
from pathlib import Path


def write_if_missing(path: Path, content: str) -> None:
    if not path.exists():
        path.write_text(content)


def main() -> None:
    parser = argparse.ArgumentParser(description="Initialize meta-analysis project folders.")
    parser.add_argument("--root", default=".", help="Project root (default: current directory)")
    args = parser.parse_args()

    root = Path(args.root).resolve()

    dirs = [
        "01_protocol",
        "02_search/round-01",
        "03_screening/round-01",
        "04_fulltext",
        "05_extraction",
        "06_analysis/figures",
        "06_analysis/tables",
        "07_manuscript",
        "08_reviews",
        "09_qa",
        "09_qa/checkpoints",
        "tooling/python",
    ]

    for d in dirs:
        (root / d).mkdir(parents=True, exist_ok=True)

    write_if_missing(root / "TOPIC.txt", "<Paste your meta-analysis topic here>\n")

    checklist = """# Pipeline Checklist

- [ ] 01_protocol complete (PICO, eligibility, outcomes, search plan)
- [ ] 02_search round-01 complete (queries, results, dedupe, log)
- [ ] 03_screening round-01 complete (decisions, exclusions, quality, included)
- [ ] 04_fulltext complete (manifest + PDFs)
- [ ] 05_extraction complete (db, csv, data dictionary, log)
- [ ] 06_analysis complete (scripts, figures, tables, validation)
- [ ] 07_manuscript complete (IMRaD + renders)
- [ ] 08_reviews complete (reviewer1, reviewer2, action items)
"""
    write_if_missing(root / "09_qa" / "pipeline-checklist.md", checklist)


if __name__ == "__main__":
    main()
