#!/usr/bin/env python3
"""
Merge missing mob_spawn_points rows from LandSandBoat upstream into local sql/.

Adds any LSB spawn row whose mobid is not already present locally. Existing local
rows are never removed or overwritten.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

INSERT_RE = re.compile(r"^INSERT INTO `mob_spawn_points` VALUES \((\d+),")


def load_mobids(path: Path) -> set[int]:
    mobids: set[int] = set()
    with path.open(encoding="utf-8") as f:
        for line in f:
            m = INSERT_RE.match(line)
            if m:
                mobids.add(int(m.group(1)))
    return mobids


def collect_missing_inserts(lsb_path: Path, local_mobids: set[int]) -> list[str]:
    missing: list[str] = []
    with lsb_path.open(encoding="utf-8") as f:
        for line in f:
            m = INSERT_RE.match(line)
            if not m:
                continue
            mobid = int(m.group(1))
            if mobid not in local_mobids:
                missing.append(line if line.endswith("\n") else line + "\n")
    return missing


def zone_stats(lines: list[str]) -> dict[int, int]:
    counts: dict[int, int] = {}
    for line in lines:
        m = INSERT_RE.match(line)
        if m:
            z = (int(m.group(1)) >> 12) & 0xFFF
            counts[z] = counts.get(z, 0) + 1
    return counts


def resolve_lsb_path(explicit: Path | None) -> Path:
    if explicit:
        return explicit
    repo = Path(__file__).resolve().parent.parent
    candidates = [
        repo.parent / "lsb-tmp" / "sql" / "mob_spawn_points.sql",
        Path.home()
        / ".cursor"
        / "projects"
        / "c-PegasusXI-server"
        / "lsb-tmp"
        / "sql"
        / "mob_spawn_points.sql",
        repo.parent / "LandSandBoat-server-base" / "sql" / "mob_spawn_points.sql",
    ]
    for path in candidates:
        if path.is_file():
            return path
    raise SystemExit(
        "LSB mob_spawn_points.sql not found. Pass --lsb or clone with "
        "tools/import_lsb_mob_tables.ps1 -CloneFromGit"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--local",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "sql" / "mob_spawn_points.sql",
    )
    parser.add_argument(
        "--lsb",
        type=Path,
        default=None,
        help="LandSandBoat mob_spawn_points.sql (auto-detected if omitted).",
    )
    parser.add_argument(
        "--patch-out",
        type=Path,
        default=None,
        help="Write incremental INSERT patch to this path.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Report counts only; do not modify local SQL.",
    )
    args = parser.parse_args()
    args.lsb = resolve_lsb_path(args.lsb)

    if not args.local.is_file():
        raise SystemExit(f"Local file not found: {args.local}")
    if not args.lsb.is_file():
        raise SystemExit(f"LSB file not found: {args.lsb}")

    local_mobids = load_mobids(args.local)
    missing = collect_missing_inserts(args.lsb, local_mobids)
    by_zone = zone_stats(missing)

    print(f"Local mob_spawn_points: {len(local_mobids):,} rows")
    print(f"Missing from LSB:         {len(missing):,} rows across {len(by_zone)} zones")

    if not missing:
        print("Nothing to merge.")
        return 0

    if args.dry_run:
        top = sorted(by_zone.items(), key=lambda kv: kv[1], reverse=True)[:15]
        print("Top zones to add:")
        for zid, count in top:
            print(f"  zone {zid:4}: +{count}")
        return 0

    header = (
        "\n-- ------------------------------------------------------------\n"
        f"-- Merged from LandSandBoat upstream ({args.lsb.name})\n"
        f"-- Added {len(missing):,} missing spawn rows\n"
        "-- ------------------------------------------------------------\n"
    )

    text = args.local.read_text(encoding="utf-8")
    footer_marker = "SET FOREIGN_KEY_CHECKS=1;"
    if footer_marker in text:
        idx = text.rfind(footer_marker)
        merged = text[:idx] + header + "".join(missing) + text[idx:]
    else:
        merged = text.rstrip() + "\n" + header + "".join(missing) + footer_marker + "\n"

    args.local.write_text(merged, encoding="utf-8", newline="\n")
    print(f"Updated {args.local} (+{len(missing):,} rows)")

    if args.patch_out:
        patch = (
            "-- Incremental mob_spawn_points from LandSandBoat upstream\n"
            "SET NAMES utf8mb4;\n"
            "SET FOREIGN_KEY_CHECKS=0;\n"
            + "".join(missing)
            + "SET FOREIGN_KEY_CHECKS=1;\n"
        )
        args.patch_out.parent.mkdir(parents=True, exist_ok=True)
        args.patch_out.write_text(patch, encoding="utf-8", newline="\n")
        print(f"Wrote patch {args.patch_out}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
