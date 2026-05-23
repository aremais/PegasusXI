#!/usr/bin/env python3
"""
Validate referential integrity of sql/mob_pools.sql against
sql/mob_species_system.sql and sql/mob_family_system.sql.

Background: mob_pools.speciesid is INNER JOINed to mob_species_system.speciesID
at runtime (src/map/utils/mobutils.cpp). If a pool's speciesid does not exist
in mob_species_system, the mob will fail to load or load with corrupt data.

A previous commit (f8e943d7) introduced ~3600 corrupt speciesid values caused by
a stale schema comment at the bottom of mob_pools.sql that still labelled the
4th column as `familyid`. PR #198 reverted those rewrites; this script enforces
that mob_pools.speciesid always references a valid speciesID and never a
familyID, and that no pool falls back to the column default of 0.

Any pool that needs to point at a species mob_species_system does not yet model
must add that row to sql/mob_species_system.sql first, or be aliased onto an
existing close-fit species (e.g. Mammet Trust onto species 483 Mammet). New
placeholder rows with speciesid=0 are rejected so the loader's INNER JOIN never
silently drops them.

Exit code: 0 = ok, 1 = invalid references.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql"


def parse_inserts(path: Path, table: str) -> list[list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    pattern = rf"INSERT INTO `{table}` VALUES \((.+?)\);"
    rows: list[list[str]] = []
    for m in re.finditer(pattern, text, re.DOTALL):
        vals = m.group(1)
        parts: list[str] = []
        cur = ""
        in_q = False
        for ch in vals:
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


def main() -> int:
    species_rows = parse_inserts(SQL / "mob_species_system.sql", "mob_species_system")
    family_rows = parse_inserts(SQL / "mob_family_system.sql", "mob_family_system")
    pool_rows = parse_inserts(SQL / "mob_pools.sql", "mob_pools")

    species_ids = {int(r[0]) for r in species_rows}
    family_ids = {int(r[0]) for r in family_rows}

    missing: list[tuple[int, str, int]] = []
    looks_like_family: list[tuple[int, str, int]] = []
    zero: list[tuple[int, str]] = []

    for r in pool_rows:
        if len(r) < 4:
            continue
        try:
            pool_id = int(r[0])
            species_id = int(r[3])
        except ValueError:
            continue
        name = r[1].strip("'")
        if species_id == 0:
            zero.append((pool_id, name))
            missing.append((pool_id, name, species_id))
        elif species_id not in species_ids:
            missing.append((pool_id, name, species_id))
            if species_id in family_ids:
                looks_like_family.append((pool_id, name, species_id))

    print(f"mob_species_system rows: {len(species_ids)}")
    print(f"mob_family_system  rows: {len(family_ids)}")
    print(f"mob_pools          rows: {len(pool_rows)}")
    print(f"pools with bad speciesid: {len(missing)}")
    print(f"  ... with speciesid=0 (column default — never valid): {len(zero)}")
    print(f"  ... of those, speciesid value matches a familyID (schema-confusion symptom): {len(looks_like_family)}")

    if missing:
        print("\nFirst 20 invalid references:")
        for pid, name, sid in missing[:20]:
            if (pid, name) in zero:
                tag = " (zero default)"
            elif (pid, name, sid) in looks_like_family:
                tag = " (matches familyID)"
            else:
                tag = ""
            print(f"  pool {pid:>5} {name!r:30} speciesid={sid}{tag}")
        return 1
    print("\nOK: every mob_pools.speciesid resolves to a real mob_species_system.speciesID")
    return 0


if __name__ == "__main__":
    sys.exit(main())
