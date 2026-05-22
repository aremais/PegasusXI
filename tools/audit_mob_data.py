#!/usr/bin/env python3
"""Audit mob_family_system, mob_pools, and related aggro/detection data."""
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DETECT_NAMES = {
    0: "NONE",
    1: "SIGHT",
    2: "HEARING",
    3: "SIGHT+HEARING",
    4: "LOWHP",
    8: "NONE1",
    16: "NONE2",
    32: "MAGIC",
    64: "WS",
    128: "JA",
    256: "SCENT",
}


def decode(d: int) -> str:
    bits = [DETECT_NAMES[b] for b in [1, 2, 4, 8, 16, 32, 64, 128, 256] if d & b]
    return "+".join(bits) if bits else "NONE"


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


def main() -> None:
    families = {}
    for parts in parse_inserts(ROOT / "sql/mob_family_system.sql", "mob_family_system"):
        fid = int(parts[0])
        families[fid] = {
            "family": parts[1].strip("'"),
            "superFamilyID": int(parts[2]),
            "superFamily": parts[3].strip("'"),
            "ecosystemID": int(parts[4]),
            "ecosystem": parts[5].strip("'"),
            "detects": int(parts[21]),
        }

    pools = {}
    true_det_pools = []
    aggro_pools = []
    for parts in parse_inserts(ROOT / "sql/mob_pools.sql", "mob_pools"):
        pid = int(parts[0])
        name = parts[1].strip("'")
        familyid = int(parts[3])
        aggro = int(parts[11])
        true_det = int(parts[12])
        pools[pid] = {
            "name": name,
            "familyid": familyid,
            "aggro": aggro,
            "true_detection": true_det,
        }
        if true_det:
            true_det_pools.append((pid, name, familyid))
        if aggro:
            aggro_pools.append((pid, name, familyid))

    print("=== MOB DATA AUDIT ===")
    print(f"Families: {len(families)}, Pools: {len(pools)}")
    print(f"Aggro pools: {len(aggro_pools)}, True detection pools: {len(true_det_pools)}")

    no_detect = [f for f, v in families.items() if v["detects"] == 0]
    print(f"\nFamilies with detects=0: {len(no_detect)}")
    for f in no_detect[:15]:
        print(f"  {f}: {families[f]['family']} ({families[f]['ecosystem']})")

    by_super = defaultdict(list)
    for fid, v in families.items():
        by_super[v["superFamilyID"]].append((fid, v["family"], v["detects"], v["superFamily"]))

    inconsistent_super = []
    for sid, members in by_super.items():
        detects_set = {d for _, _, d, _ in members}
        if len(detects_set) > 1 and sid != 0:
            inconsistent_super.append(
                (sid, members[0][3], detects_set, len(members), members)
            )

    print(f"\nSuperfamilies with mixed detection types: {len(inconsistent_super)}")
    for sid, sname, dset, cnt, members in sorted(inconsistent_super, key=lambda x: -x[3])[:20]:
        print(f"  superFamily {sid} ({sname}): {cnt} families")
        for fid, fname, d, _ in sorted(members, key=lambda x: x[2])[:8]:
            print(f"    {fid:4} {fname:24} -> {decode(d)} ({d})")
        if cnt > 8:
            print(f"    ... and {cnt - 8} more")

    bad_aggro = []
    for pid, name, fid in aggro_pools:
        if families.get(fid, {}).get("detects", -1) == 0:
            bad_aggro.append((pid, name, fid, families[fid]["family"]))
    print(f"\nAggro pools whose family has detects=0: {len(bad_aggro)}")
    for x in bad_aggro[:20]:
        print(f"  pool {x[0]}: {x[1]} -> family {x[2]} ({x[3]})")

    print(f"\nAll true_detection pools ({len(true_det_pools)}):")
    for pid, name, fid in sorted(true_det_pools):
        fam = families.get(fid, {})
        print(
            f"  pool {pid:5}: {name:32} | fam {fid:3} {fam.get('family', '?'):20} | {decode(fam.get('detects', 0))}"
        )

    # Sight+hearing family but true detection pool (common misconfig for sneak/invis reports)
    suspect = []
    for pid, name, fid in true_det_pools:
        d = families.get(fid, {}).get("detects", 0)
        if d in (1, 2, 3):  # sight, sound, or both - not magic/scent only
            suspect.append((pid, name, fid, d))
    print(f"\nTrue detection on sight/sound families (likely breaks sneak+invis): {len(suspect)}")
    for row in suspect:
        print(f"  pool {row[0]}: {row[1]} family detects={decode(row[3])}")

    missing_fam = [(p, v) for p, v in pools.items() if v["familyid"] not in families]
    print(f"\nPools with invalid familyid: {len(missing_fam)}")
    for p, v in missing_fam[:10]:
        print(f"  pool {p}: {v['name']} familyid={v['familyid']}")

    # Detection distribution
    dist = defaultdict(int)
    for v in families.values():
        dist[v["detects"]] += 1
    print("\nFamily detection value distribution:")
    for d in sorted(dist):
        print(f"  {d:4} ({decode(d):20}): {dist[d]} families")


if __name__ == "__main__":
    main()
