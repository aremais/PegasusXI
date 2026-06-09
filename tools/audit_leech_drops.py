#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def parse(line):
    parts = line.split("VALUES (", 1)[1].rstrip(");\n")
    return [v.strip().strip("'") for v in re.split(r",(?=(?:[^']*'[^']*')*[^']*$)", parts)]

pools = {}
with open(ROOT / "sql/mob_pools.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_pools` VALUES \((\d+),'([^']+)'", line)
        if m and "Leech" in m.group(2) and "Leecher" not in m.group(2) and "Leechkeeper" not in m.group(2):
            pools[int(m.group(1))] = m.group(2)

dropids = {}
groups_zero = []
with open(ROOT / "sql/mob_groups.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_groups` VALUES \((\d+),(\d+),(\d+),'([^']+)'", line)
        if not m:
            continue
        poolid = int(m.group(2))
        if poolid in pools:
            vals = parse(line)
            did = int(vals[6])
            dropids.setdefault(did, set()).add(pools[poolid])
            if did == 0:
                groups_zero.append((int(m.group(3)), pools[poolid], int(m.group(1))))

has = set()
with open(ROOT / "sql/mob_droplist.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_droplist` VALUES \((\d+),", line)
        if m and ",1125,@" in line:
            has.add(int(m.group(1)))

print("=== dropId status ===")
for did in sorted(dropids):
    status = "OK" if did in has else ("ZERO" if did == 0 else "MISSING")
    print(f"{status:7} {did:5}: {sorted(dropids[did])}")

print("\n=== dropId 0 spawns ===")
for zone, name, gid in sorted(groups_zero):
    print(f"  zone {zone} group {gid}: {name}")
