#!/usr/bin/env python3
"""Find mob_pools where familyid was confused with resist_id."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def parse_inserts(path: Path, table: str) -> list[list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    pattern = rf"INSERT INTO `{table}` VALUES \((.+?)\);"
    rows = []
    for m in re.finditer(pattern, text, re.DOTALL):
        vals = m.group(1)
        parts = []
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


def norm(s: str) -> str:
    return s.replace("'", "").replace("-", "_").lower()


def main() -> None:
    families = {
        int(p[0]): p[1].strip("'")
        for p in parse_inserts(ROOT / "sql/mob_family_system.sql", "mob_family_system")
    }
    family_detects = {
        int(p[0]): int(p[21])
        for p in parse_inserts(ROOT / "sql/mob_family_system.sql", "mob_family_system")
    }
    resists = {
        int(p[0]): p[1].strip("'")
        for p in parse_inserts(ROOT / "sql/mob_resistances.sql", "mob_resistances")
    }

    def family_for_resist(rid: int) -> int | None:
        rn = norm(resists.get(rid, ""))
        matches = [fid for fid, fn in families.items() if norm(fn) == rn]
        return matches[0] if len(matches) == 1 else None

    bad = []
    zero_det_aggro = []
    for parts in parse_inserts(ROOT / "sql/mob_pools.sql", "mob_pools"):
        if len(parts) <= 25:
            continue
        pid = int(parts[0])
        name = parts[1].strip("'")
        fid = int(parts[3])
        aggro = int(parts[11])
        rid = int(parts[25])
        if not aggro:
            continue
        if family_detects.get(fid, -1) == 0:
            zero_det_aggro.append((pid, name, fid, families.get(fid, "?")))
        exp = family_for_resist(rid)
        if exp is None or fid == exp:
            continue
        bad.append(
            (
                pid,
                name,
                fid,
                families.get(fid, "?"),
                rid,
                resists.get(rid, "?"),
                exp,
                families.get(exp, "?"),
            )
        )

    print(f"Aggro pools with familyid != resist-name family: {len(bad)}")
    for row in sorted(bad, key=lambda x: x[1]):
        print(
            f"  {row[0]:5} {row[1]:28} fid={row[2]:3}({row[3]}) "
            f"resist={row[4]:3}({row[5]}) -> {row[6]:3}({row[7]})"
        )

    print(f"\nAggro pools on families with detects=0: {len(zero_det_aggro)}")
    for row in sorted(zero_det_aggro, key=lambda x: x[1])[:30]:
        print(f"  {row[0]:5} {row[1]:28} family {row[2]:3} ({row[3]})")
    if len(zero_det_aggro) > 30:
        print(f"  ... {len(zero_det_aggro) - 30} more")


if __name__ == "__main__":
    main()
