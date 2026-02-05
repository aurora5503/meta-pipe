#!/usr/bin/env python3
"""Compare numeric claims in Abstract vs Results."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

NUMBER_RE = re.compile(r"\b\d+(?:\.\d+)?%?\b")


def extract_numbers(text: str) -> set[str]:
    return set(NUMBER_RE.findall(text))


def main() -> None:
    parser = argparse.ArgumentParser(description="Audit numeric claims in abstract vs results.")
    parser.add_argument("--abstract", required=True, help="Abstract file path")
    parser.add_argument("--results", required=True, help="Results file path")
    parser.add_argument("--out", required=True, help="Output markdown report")
    args = parser.parse_args()

    abstract_path = Path(args.abstract)
    results_path = Path(args.results)

    if not abstract_path.exists():
        raise SystemExit(f"Missing abstract file: {abstract_path}")
    if not results_path.exists():
        raise SystemExit(f"Missing results file: {results_path}")

    abstract_numbers = extract_numbers(abstract_path.read_text())
    results_numbers = extract_numbers(results_path.read_text())

    missing = sorted(abstract_numbers - results_numbers)

    lines = [
        "# Claim Audit (Abstract vs Results)",
        "",
        f"Abstract numeric tokens: {len(abstract_numbers)}",
        f"Results numeric tokens: {len(results_numbers)}",
        "",
        "## Numbers in Abstract Not Found in Results",
    ]

    if missing:
        for item in missing:
            lines.append(f"- {item}")
    else:
        lines.append("- None")

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
