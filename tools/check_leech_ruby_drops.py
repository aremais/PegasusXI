#!/usr/bin/env python3
"""Find leech droplists missing Carbuncle's Ruby (item 1125)."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def parse_insert_values(line: str) -> list[str]:
    parts = line.split("VALUES (", 1)[1].rstrip(");\n")
    return [v.strip().strip("'") for v in re.split(r",(?=(?:[^']*'[^']*')*[^']*$)", parts)]

# Leech mob pools (exclude Goblin Leecher / Leechkeeper)
pools: dict[int, str] = {}
with open(ROOT / "sql/mob_pools.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_pools` VALUES \((\d+),'([^']+)'", line)
        if not m:
            continue
        pid, name = int(m.group(1)), m.group(2)
        if "Leech" in name and "Leecher" not in name and "Leechkeeper" not in name:
            pools[pid] = name

# dropId -> pool names
dropids: dict[int, set[str]] = {}
with open(ROOT / "sql/mob_groups.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_groups` VALUES \((\d+),(\d+),(\d+),'([^']+)'", line)
        if not m:
            continue
        poolid = int(m.group(2))
        if poolid in pools:
            vals = parse_insert_values(line)
            dropid = int(vals[6])
            dropids.setdefault(dropid, set()).add(pools[poolid])

# dropIds that already have item 1125
has_ruby: set[int] = set()
drop_first_line: dict[int, tuple[int, str]] = {}
with open(ROOT / "sql/mob_droplist.sql", encoding="utf-8") as f:
    for i, line in enumerate(f, 1):
        m = re.match(r"INSERT INTO `mob_droplist` VALUES \((\d+),", line)
        if not m:
            continue
        did = int(m.group(1))
        if did in dropids and did not in drop_first_line:
            drop_first_line[did] = (i, line)
        if re.search(r",1125,@|,1125\)", line):
            has_ruby.add(did)

missing = {did: names for did, names in sorted(dropids.items()) if did not in has_ruby}

print(f"Leech pool count: {len(pools)}")
print(f"Unique dropids for leeches: {len(dropids)}")
print(f"Dropids with ruby: {len([d for d in dropids if d in has_ruby])}")
print(f"Missing ruby ({len(missing)} dropids):")
for did, names in sorted(missing.items()):
    print(f"  dropId {did}: {sorted(names)}")
