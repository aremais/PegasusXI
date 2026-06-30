#!/usr/bin/env python3
"""Audit mob_pools.speciesid across the entire server vs upstream LandSandBoat.

Outputs:
  tools/reports/species_audit_summary.md
  tools/reports/species_audit_mismatches.csv
  tools/reports/species_audit_local_only.csv
  tools/reports/species_audit_by_zone.csv
"""
from __future__ import annotations

import csv
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = ROOT / "tools" / "reports"
MOB_POOLS = ROOT / "sql" / "mob_pools.sql"
MOB_GROUPS = ROOT / "sql" / "mob_groups.sql"
MOB_SPECIES = ROOT / "sql" / "mob_species_system.sql"
ZONE_SETTINGS = ROOT / "sql" / "zone_settings.sql"

INSERT_RE = re.compile(r"INSERT INTO `(\w+)` VALUES \((.+?)\);", re.DOTALL)

CRYSTAL_NAMES = {
    0: "None",
    1: "Fire",
    2: "Ice",
    3: "Wind",
    4: "Earth",
    5: "Lightning",
    6: "Water",
    7: "Light",
    8: "Dark",
}


@dataclass
class PoolRow:
    poolid: int
    name: str
    packet_name: str
    speciesid: int


@dataclass
class SpeciesRow:
    speciesid: int
    species: str
    element: int


def parse_insert_rows(path: Path, table: str) -> list[list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    rows: list[list[str]] = []
    for match in INSERT_RE.finditer(text):
        if match.group(1) != table:
            continue
        parts: list[str] = []
        cur = ""
        in_q = False
        for ch in match.group(2):
            if ch == "'" and (not cur or cur[-1] != "\\"):
                in_q = not in_q
                cur += ch
            elif ch == "," and not in_q:
                parts.append(cur.strip())
                cur = ""
            else:
                cur += ch
        if cur:
            parts.append(cur.strip())
        rows.append(parts)
    return rows


def unquote(value: str) -> str:
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    return value


def parse_pools(path: Path) -> dict[int, PoolRow]:
    out: dict[int, PoolRow] = {}
    for parts in parse_insert_rows(path, "mob_pools"):
        out[int(parts[0])] = PoolRow(
            poolid=int(parts[0]),
            name=unquote(parts[1]),
            packet_name=unquote(parts[2]),
            speciesid=int(parts[3]),
        )
    return out


def parse_species(path: Path) -> dict[int, SpeciesRow]:
    out: dict[int, SpeciesRow] = {}
    for parts in parse_insert_rows(path, "mob_species_system"):
        element_raw = parts[20]
        element = int(float(element_raw))
        out[int(parts[0])] = SpeciesRow(
            speciesid=int(parts[0]),
            species=unquote(parts[1]),
            element=element,
        )
    return out


def parse_groups(path: Path) -> dict[int, list[tuple[int, str]]]:
    """poolid -> list of (zoneid, mob_name)."""
    out: dict[int, list[tuple[int, str]]] = defaultdict(list)
    for parts in parse_insert_rows(path, "mob_groups"):
        poolid = int(parts[1])
        zoneid = int(parts[2])
        name = unquote(parts[3])
        if poolid > 0:
            out[poolid].append((zoneid, name))
    return out


def parse_zones(path: Path) -> dict[int, str]:
    out: dict[int, str] = {}
    for parts in parse_insert_rows(path, "zone_settings"):
        out[int(parts[0])] = unquote(parts[4])
    return out


def load_upstream_pools() -> dict[int, PoolRow]:
    text = subprocess.check_output(
        ["git", "show", "upstream/base:sql/mob_pools.sql"],
        cwd=ROOT,
        text=True,
        errors="replace",
    )
    out: dict[int, PoolRow] = {}
    for match in INSERT_RE.finditer(text):
        if match.group(1) != "mob_pools":
            continue
        parts: list[str] = []
        cur = ""
        in_q = False
        for ch in match.group(2):
            if ch == "'" and (not cur or cur[-1] != "\\"):
                in_q = not in_q
                cur += ch
            elif ch == "," and not in_q:
                parts.append(cur.strip())
                cur = ""
            else:
                cur += ch
        if cur:
            parts.append(cur.strip())
        out[int(parts[0])] = PoolRow(
            poolid=int(parts[0]),
            name=unquote(parts[1]),
            packet_name=unquote(parts[2]),
            speciesid=int(parts[3]),
        )
    return out


def crystal_label(species: dict[int, SpeciesRow], speciesid: int) -> str:
    row = species.get(speciesid)
    if not row:
        return f"Unknown({speciesid})"
    name = CRYSTAL_NAMES.get(row.element, f"?({row.element})")
    return f"{name} [{row.species}]"


def zone_summary(
    pool_zones: dict[int, list[tuple[int, str]]],
    zones: dict[int, str],
    poolids: set[int],
) -> str:
    seen: set[tuple[int, str]] = set()
    for poolid in poolids:
        for zoneid, mob_name in pool_zones.get(poolid, []):
            seen.add((zoneid, mob_name))
    if not seen:
        return ""
    parts = []
    for zoneid, mob_name in sorted(seen):
        zname = zones.get(zoneid, f"zone_{zoneid}")
        parts.append(f"{zname}({zoneid}):{mob_name}")
    return "; ".join(parts)


def main() -> int:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    local_pools = parse_pools(MOB_POOLS)
    upstream_pools = load_upstream_pools()
    species = parse_species(MOB_SPECIES)
    pool_zones = parse_groups(MOB_GROUPS)
    zones = parse_zones(ZONE_SETTINGS)

    local_ids = set(local_pools)
    upstream_ids = set(upstream_pools)
    shared = local_ids & upstream_ids
    mismatches = sorted(pid for pid in shared if local_pools[pid].speciesid != upstream_pools[pid].speciesid)
    local_only = sorted(local_ids - upstream_ids)
    upstream_only = sorted(upstream_ids - local_ids)
    matching = sorted(pid for pid in shared if local_pools[pid].speciesid == upstream_pools[pid].speciesid)

    # --- mismatches CSV ---
    mismatch_path = REPORT_DIR / "species_audit_mismatches.csv"
    with mismatch_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "poolid",
                "pool_name",
                "local_speciesid",
                "local_species",
                "local_crystal",
                "upstream_speciesid",
                "upstream_species",
                "upstream_crystal",
                "crystal_changed",
                "zones",
            ]
        )
        crystal_changed = 0
        for poolid in mismatches:
            local = local_pools[poolid]
            upstream = upstream_pools[poolid]
            local_species = species.get(local.speciesid)
            upstream_species = species.get(upstream.speciesid)
            local_elem = local_species.element if local_species else -1
            upstream_elem = upstream_species.element if upstream_species else -1
            changed = local_elem != upstream_elem
            if changed:
                crystal_changed += 1
            writer.writerow(
                [
                    poolid,
                    local.name,
                    local.speciesid,
                    local_species.species if local_species else "",
                    CRYSTAL_NAMES.get(local_elem, str(local_elem)),
                    upstream.speciesid,
                    upstream_species.species if upstream_species else "",
                    CRYSTAL_NAMES.get(upstream_elem, str(upstream_elem)),
                    "yes" if changed else "no",
                    zone_summary(pool_zones, zones, {poolid}),
                ]
            )

    # --- local-only CSV ---
    local_only_path = REPORT_DIR / "species_audit_local_only.csv"
    with local_only_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["poolid", "pool_name", "speciesid", "species", "crystal", "zones"])
        for poolid in local_only:
            pool = local_pools[poolid]
            sp = species.get(pool.speciesid)
            writer.writerow(
                [
                    poolid,
                    pool.name,
                    pool.speciesid,
                    sp.species if sp else "",
                    CRYSTAL_NAMES.get(sp.element, "") if sp else "",
                    zone_summary(pool_zones, zones, {poolid}),
                ]
            )

    # --- by zone summary ---
    zone_stats: dict[int, dict[str, int]] = defaultdict(lambda: defaultdict(int))
    for poolid in mismatches:
        for zoneid, _ in pool_zones.get(poolid, []):
            zone_stats[zoneid]["mismatched_pools"] += 1
    for poolid in matching:
        for zoneid, _ in pool_zones.get(poolid, []):
            zone_stats[zoneid]["matching_pools"] += 1

    by_zone_path = REPORT_DIR / "species_audit_by_zone.csv"
    with by_zone_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["zoneid", "zone_name", "mismatched_spawn_pools", "matching_spawn_pools"])
        for zoneid in sorted(zone_stats):
            writer.writerow(
                [
                    zoneid,
                    zones.get(zoneid, ""),
                    zone_stats[zoneid]["mismatched_pools"],
                    zone_stats[zoneid]["matching_pools"],
                ]
            )

    # --- top wrong local species (systematic swap patterns) ---
    wrong_species_counts: dict[tuple[int, str], int] = defaultdict(int)
    for poolid in mismatches:
        local = local_pools[poolid]
        sp = species.get(local.speciesid)
        key = (local.speciesid, sp.species if sp else "?")
        wrong_species_counts[key] += 1
    top_wrong = sorted(wrong_species_counts.items(), key=lambda x: -x[1])[:15]

    # --- summary markdown ---
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    summary_path = REPORT_DIR / "species_audit_summary.md"
    lines = [
        "# Mob Pool Species ID Audit",
        "",
        f"Generated: {ts}",
        f"Compared: `{MOB_POOLS.name}` vs `upstream/base:sql/mob_pools.sql`",
        "",
        "## Executive summary",
        "",
        "Species IDs in `mob_pools` drive crystal drops (via `mob_species_system.Element`),",
        "family stats, ecosystem, charmability, and detection. Item drops use separate",
        "`mob_groups.dropid` tables and were not part of this audit.",
        "",
        "| Metric | Count |",
        "| --- | ---: |",
        f"| Local mob pools | {len(local_pools):,} |",
        f"| Upstream mob pools | {len(upstream_pools):,} |",
        f"| Shared pool IDs | {len(shared):,} |",
        f"| **Species ID mismatches** | **{len(mismatches):,}** |",
        f"| Pools matching upstream | {len(matching):,} |",
        f"| Mismatches with crystal element change | {crystal_changed:,} |",
        f"| Local-only pools (no upstream row) | {len(local_only):,} |",
        f"| Upstream-only pools (missing locally) | {len(upstream_only):,} |",
        "",
        f"**{len(mismatches) / max(len(shared), 1) * 100:.1f}%** of shared pools have incorrect species IDs.",
        "",
        "## Report files",
        "",
        "| File | Description |",
        "| --- | --- |",
        f"| `{mismatch_path.relative_to(ROOT)}` | All {len(mismatches):,} mismatched pools with local vs upstream species/crystal |",
        f"| `{local_only_path.relative_to(ROOT)}` | {len(local_only):,} custom/local pools without upstream reference |",
        f"| `{by_zone_path.relative_to(ROOT)}` | Mismatch counts grouped by zone |",
        "",
        "## Most common incorrect local species IDs",
        "",
        "These species IDs appear most often where upstream expects something else —",
        "likely systematic column corruption rather than random drift.",
        "",
        "| Count | Local speciesID | Local species name |",
        "| ---: | ---: | --- |",
    ]
    for (sid, sname), count in top_wrong:
        lines.append(f"| {count:,} | {sid} | {sname} |")

    lines.extend(
        [
            "",
            "## Zones with the most mismatched spawn pools",
            "",
            "| Zone | Mismatched pools | Matching pools |",
            "| --- | ---: | ---: |",
        ]
    )
    top_zones = sorted(
        zone_stats.items(),
        key=lambda x: -x[1]["mismatched_pools"],
    )[:25]
    for zoneid, stats in top_zones:
        if stats["mismatched_pools"] == 0:
            continue
        lines.append(
            f"| {zones.get(zoneid, zoneid)} ({zoneid}) | "
            f"{stats['mismatched_pools']:,} | {stats['matching_pools']:,} |"
        )

    lines.extend(
        [
            "",
            "## Recommended next steps",
            "",
            "1. Review `species_audit_local_only.csv` for intentional custom content before bulk-fixing.",
            "2. Bulk-fix the ~{:,} upstream-backed mismatches (scripted UPDATE from upstream values).".format(
                len(mismatches)
            ),
            "3. Restart all `xi_map` processes after DB/SQL changes.",
            "4. Spot-check crystal drops in a few signet regions (Gustaberg, Ronfaure, Saruta).",
            "5. Run separately: `python tools/fix_mob_aggro_data.py` if resist_id/detection issues remain.",
            "",
            "## Already fixed",
            "",
            "South Gustaberg (zone 107): 46 pools corrected via `tools/fix_south_gustaberg_species.py`.",
            "Those pools should show as matching upstream if re-audited in isolation.",
            "",
        ]
    )

    summary_path.write_text("\n".join(lines), encoding="utf-8")

    print(f"Wrote {summary_path}")
    print(f"Wrote {mismatch_path} ({len(mismatches)} rows)")
    print(f"Wrote {local_only_path} ({len(local_only)} rows)")
    print(f"Wrote {by_zone_path} ({len(zone_stats)} zones)")
    print()
    print(f"Local pools: {len(local_pools)}")
    print(f"Species mismatches: {len(mismatches)}")
    print(f"Crystal element would change: {crystal_changed}")
    print(f"Local-only pools: {len(local_only)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
