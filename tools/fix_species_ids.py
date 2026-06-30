#!/usr/bin/env python3
"""Bulk-fix mob_pools.speciesid from upstream LandSandBoat for all shared pool IDs.

Skips local-only pools (no upstream row). Updates sql/mob_pools.sql and xidb.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOB_POOLS = ROOT / "sql" / "mob_pools.sql"
INSERT_RE = re.compile(r"INSERT INTO `mob_pools` VALUES \((.+?)\);", re.DOTALL)

DB_ARGS = ["-h", "127.0.0.1", "-u", "root", "-pFr0styP1n3!", "xidb"]
BATCH_SIZE = 500


def parse_species(text: str) -> dict[int, int]:
    out: dict[int, int] = {}
    for match in INSERT_RE.finditer(text):
        parts: list[str] = []
        cur = ""
        in_q = False
        for ch in match.group(1):
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
        out[int(parts[0])] = int(parts[3])
    return out


def load_upstream_species() -> dict[int, int]:
    text = subprocess.check_output(
        ["git", "show", "upstream/base:sql/mob_pools.sql"],
        cwd=ROOT,
        text=True,
        errors="replace",
    )
    return parse_species(text)


def format_values(parts: list[str]) -> str:
    return ",".join(parts)


def fix_sql(fixes: dict[int, int]) -> int:
    text = MOB_POOLS.read_text(encoding="utf-8", errors="replace")
    changed = 0

    def repl(match: re.Match[str]) -> str:
        nonlocal changed
        parts: list[str] = []
        cur = ""
        in_q = False
        for ch in match.group(1):
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

        poolid = int(parts[0])
        if poolid not in fixes:
            return match.group(0)

        new_species = fixes[poolid]
        if int(parts[3]) == new_species:
            return match.group(0)

        parts[3] = str(new_species)
        changed += 1
        return f"INSERT INTO `mob_pools` VALUES ({format_values(parts)});"

    new_text = INSERT_RE.sub(repl, text)
    if changed:
        MOB_POOLS.write_text(new_text, encoding="utf-8")
    return changed


def apply_db(fixes: dict[int, int]) -> None:
    items = sorted(fixes.items())
    for i in range(0, len(items), BATCH_SIZE):
        batch = items[i : i + BATCH_SIZE]
        case_lines = "\n".join(
            f"    WHEN {poolid} THEN {speciesid}" for poolid, speciesid in batch
        )
        poolids = ", ".join(str(pid) for pid, _ in batch)
        sql = (
            f"UPDATE mob_pools SET speciesid = CASE poolid\n{case_lines}\n"
            f"    ELSE speciesid END\n"
            f"WHERE poolid IN ({poolids});"
        )
        subprocess.run(
            ["mysql", *DB_ARGS, "-e", sql],
            check=True,
            capture_output=True,
            text=True,
        )


def main() -> int:
    local = parse_species(MOB_POOLS.read_text(encoding="utf-8", errors="replace"))
    upstream = load_upstream_species()

    fixes = {
        poolid: upstream[poolid]
        for poolid in set(local) & set(upstream)
        if local[poolid] != upstream[poolid]
    }

    if not fixes:
        print("No species ID fixes needed.")
        return 0

    print(f"Fixing {len(fixes)} mob_pools species IDs from upstream/base...")
    sql_changed = fix_sql(fixes)
    print(f"Updated {sql_changed} rows in {MOB_POOLS}")

    apply_db(fixes)
    print(f"Applied {len(fixes)} updates to database")

    # Verify
    verify = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "audit_species_ids.py")],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    print(verify.stdout.strip())
    if verify.returncode != 0:
        print(verify.stderr, file=sys.stderr)
        return verify.returncode

    return 0


if __name__ == "__main__":
    sys.exit(main())
