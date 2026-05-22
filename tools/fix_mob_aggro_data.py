#!/usr/bin/env python3
"""
Fix mob aggro/detection data:

1. mob_pools.familyid confused with mob_resistances.resist_id (all aggro pools).
2. mob_family_system.detects=0 on true-sight/sound families (needs base SIGHT/HEARING bits).
3. mob_pools.true_detection for aggro pools on those families.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOB_POOLS = ROOT / "sql" / "mob_pools.sql"
MOB_FAMILIES = ROOT / "sql" / "mob_family_system.sql"
MOB_RESISTS = ROOT / "sql" / "mob_resistances.sql"

IDX_FAMILYID = 3
IDX_AGGRO = 11
IDX_TRUE_DET = 12
IDX_RESIST_ID = 25
IDX_DETECTS = 21

# bg-wiki: True Sight/Sound — family.detects holds base type; pool.true_detection bypasses sneak/invis
TRUE_DETECTION_FAMILY_DETECTS: dict[int, int] = {
    67: 3,   # Khimaira — true sight + true sound
    68: 3,   # Khrysokhimaira
    238: 3,  # Zilant
    322: 2,  # Hpemde — true sound
    330: 1,  # Green_Zdei — true sight
    331: 1,  # Zdei — true sight
}

# Resist rows whose name does not match a family row literally
RESIST_TO_FAMILY: dict[str, int] = {
    "Slime-Clot": 16,
    "Slime-GlutinousClot": 16,
}


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


def family_id_for_resist_name(resist_name: str, families: dict) -> int | None:
    if resist_name in RESIST_TO_FAMILY:
        return RESIST_TO_FAMILY[resist_name]
    rn = norm(resist_name)
    matches = [fid for fid, f in families.items() if norm(f["family"]) == rn]
    if len(matches) == 1:
        return matches[0]
    return None


def main() -> None:
    families = {}
    for parts in parse_inserts(MOB_FAMILIES, "mob_family_system"):
        fid = int(parts[0])
        families[fid] = {
            "family": parts[1].strip("'"),
            "detects": int(parts[IDX_DETECTS]),
        }

    resists = {}
    for parts in parse_inserts(MOB_RESISTS, "mob_resistances"):
        rid = int(parts[0])
        resists[rid] = parts[1].strip("'")

    family_fixes = []
    true_det_set = []

    for parts in parse_inserts(MOB_POOLS, "mob_pools"):
        if len(parts) <= IDX_RESIST_ID:
            continue
        pid = int(parts[0])
        name = parts[1].strip("'")
        familyid = int(parts[IDX_FAMILYID])
        aggro = int(parts[IDX_AGGRO])
        true_det = int(parts[IDX_TRUE_DET])
        resist_id = int(parts[IDX_RESIST_ID])

        if not aggro:
            continue

        resist_name = resists.get(resist_id)
        if resist_name:
            expected_fid = family_id_for_resist_name(resist_name, families)
            if expected_fid is not None and familyid != expected_fid:
                current = families.get(familyid)
                family_fixes.append(
                    {
                        "poolid": pid,
                        "name": name,
                        "resist_name": resist_name,
                        "old_fid": familyid,
                        "old_family": current["family"] if current else "?",
                        "new_fid": expected_fid,
                        "new_family": families[expected_fid]["family"],
                    }
                )

        expected_fid = (
            family_id_for_resist_name(resist_name, families) if resist_name else None
        )
        effective_fid = expected_fid if expected_fid is not None else familyid
        if effective_fid in TRUE_DETECTION_FAMILY_DETECTS and not true_det:
            true_det_set.append({"poolid": pid, "name": name, "familyid": effective_fid})

    print(f"Family fixes (aggro pools, resist name -> family): {len(family_fixes)}")
    for row in sorted(family_fixes, key=lambda x: x["name"])[:25]:
        print(
            f"  {row['poolid']:5} {row['name']:28} "
            f"{row['old_fid']:3}({row['old_family']}) -> {row['new_fid']:3}({row['new_family']}) "
            f"resist={row['resist_name']}"
        )
    if len(family_fixes) > 25:
        print(f"  ... and {len(family_fixes) - 25} more")

    print(f"\nSet true_detection=1 on aggro true-sight/sound families: {len(true_det_set)}")
    for row in sorted(true_det_set, key=lambda x: x["name"])[:15]:
        print(f"  {row['poolid']:5} {row['name']:28} family {row['familyid']}")
    if len(true_det_set) > 15:
        print(f"  ... and {len(true_det_set) - 15} more")

    # --- mob_family_system.sql: base detection bits ---
    fam_text = MOB_FAMILIES.read_text(encoding="utf-8", errors="replace")
    fam_patched = 0

    def patch_family(m: re.Match) -> str:
        nonlocal fam_patched
        parts = parse_row_values(m.group(1))
        fid = int(parts[0])
        if fid not in TRUE_DETECTION_FAMILY_DETECTS:
            return m.group(0)
        new_det = str(TRUE_DETECTION_FAMILY_DETECTS[fid])
        if parts[IDX_DETECTS] == new_det:
            return m.group(0)
        parts[IDX_DETECTS] = new_det
        fam_patched += 1
        return f"INSERT INTO `mob_family_system` VALUES ({','.join(parts)});"

    def parse_row_values(vals: str) -> list[str]:
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
        return parts

    fam_text = re.sub(
        r"INSERT INTO `mob_family_system` VALUES \((.+?)\);",
        patch_family,
        fam_text,
        flags=re.DOTALL,
    )
    MOB_FAMILIES.write_text(fam_text, encoding="utf-8")
    print(f"\nPatched {fam_patched} families in mob_family_system.sql")

    # --- mob_pools.sql ---
    family_by_pool = {f["poolid"]: f["new_fid"] for f in family_fixes}
    true_det_pools = {f["poolid"] for f in true_det_set}

    pool_text = MOB_POOLS.read_text(encoding="utf-8", errors="replace")
    pool_changed = 0

    def patch_pool(m: re.Match) -> str:
        nonlocal pool_changed
        parts = parse_row_values(m.group(1))
        if len(parts) <= IDX_TRUE_DET:
            return m.group(0)
        pid = int(parts[0])
        changed = False
        if pid in family_by_pool:
            parts[IDX_FAMILYID] = str(family_by_pool[pid])
            changed = True
        if pid in true_det_pools and int(parts[IDX_TRUE_DET]) == 0:
            parts[IDX_TRUE_DET] = "1"
            changed = True
        if not changed:
            return m.group(0)
        pool_changed += 1
        return f"INSERT INTO `mob_pools` VALUES ({','.join(parts)});"

    pool_text = re.sub(
        r"INSERT INTO `mob_pools` VALUES \((.+?)\);",
        patch_pool,
        pool_text,
        flags=re.DOTALL,
    )
    MOB_POOLS.write_text(pool_text, encoding="utf-8")
    print(f"Patched {pool_changed} pools in mob_pools.sql")


if __name__ == "__main__":
    main()
