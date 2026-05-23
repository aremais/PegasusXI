"""Helpers for writing CSV / Markdown audit reports."""

from __future__ import annotations

import csv
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable


def _norm(value: Any) -> Any:
    """Treat None and empty string as equivalent; coerce numerics for comparison."""
    if value is None or value == "":
        return None
    if isinstance(value, bool):
        return int(value)
    return value


def changed_fields(local: dict[str, Any], upstream: dict[str, Any], fields: Iterable[str]) -> list[str]:
    out: list[str] = []
    for f in fields:
        if _norm(local.get(f)) != _norm(upstream.get(f)):
            out.append(f)
    return out


@dataclass
class DiffRow:
    key: Any
    status: str  # "changed" | "only_local" | "only_upstream"
    local: dict[str, Any] = field(default_factory=dict)
    upstream: dict[str, Any] = field(default_factory=dict)
    changes: list[str] = field(default_factory=list)


def write_csv(path: Path, header: list[str], rows: Iterable[list[Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(header)
        for row in rows:
            w.writerow(["" if v is None else v for v in row])


def write_markdown(path: Path, title: str, sections: list[tuple[str, list[str], list[list[Any]]]]) -> None:
    """Write a Markdown report with H2 sections; each section is (heading, header_cells, rows)."""
    path.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = [f"# {title}", ""]
    for heading, header, rows in sections:
        lines.append(f"## {heading}")
        lines.append("")
        if not rows:
            lines.append("_No rows._")
            lines.append("")
            continue
        lines.append("| " + " | ".join(header) + " |")
        lines.append("| " + " | ".join(["---"] * len(header)) + " |")
        for row in rows:
            cells = []
            for v in row:
                if v is None:
                    cells.append("")
                else:
                    s = str(v).replace("|", "\\|").replace("\n", " ")
                    cells.append(s)
            lines.append("| " + " | ".join(cells) + " |")
        lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")
