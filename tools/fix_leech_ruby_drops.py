#!/usr/bin/env python3
"""Add Carbuncle's Ruby (1%) to all leech droplists."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DROP_FILE = ROOT / "sql/mob_droplist.sql"
GROUPS_FILE = ROOT / "sql/mob_groups.sql"
RUBY_LINE = "INSERT INTO `mob_droplist` VALUES ({dropid},0,0,1000,1125,@VRARE);   -- Carbuncles Ruby (Very Rare, 1%)\n"
ZERO_DROPID = 3412  # shared ruby-only droplist for leeches that had dropId 0


def parse_insert_values(line: str) -> list[str]:
    parts = line.split("VALUES (", 1)[1].rstrip(");\n")
    return [v.strip().strip("'") for v in re.split(r",(?=(?:[^']*'[^']*')*[^']*$)", parts)]


def is_leech_pool(name: str) -> bool:
    return "Leech" in name and "Leecher" not in name and "Leechkeeper" not in name


# Leech mob pools
pools: dict[int, str] = {}
with open(ROOT / "sql/mob_pools.sql", encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_pools` VALUES \((\d+),'([^']+)'", line)
        if m and is_leech_pool(m.group(2)):
            pools[int(m.group(1))] = m.group(2)

# dropId -> pool names from mob_groups
leech_dropids: dict[int, set[str]] = {}
zero_group_lines: list[str] = []
with open(GROUPS_FILE, encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_groups` VALUES \((\d+),(\d+),(\d+),'([^']+)'", line)
        if not m:
            continue
        poolid = int(m.group(2))
        if poolid in pools:
            vals = parse_insert_values(line)
            dropid = int(vals[6])
            leech_dropids.setdefault(dropid, set()).add(pools[poolid])
            if dropid == 0:
                zero_group_lines.append(line)

# dropIds that already have item 1125
has_ruby: set[int] = set()
with open(DROP_FILE, encoding="utf-8") as f:
    for line in f:
        m = re.match(r"INSERT INTO `mob_droplist` VALUES \((\d+),", line)
        if m and re.search(r",1125,@", line):
            has_ruby.add(int(m.group(1)))

missing = sorted(d for d in leech_dropids if d not in has_ruby and d != 0)
print(f"Adding ruby to dropIds: {missing}")
print(f"Creating dropId {ZERO_DROPID} for {len(zero_group_lines)} dropId-0 leech spawns")

# Patch mob_droplist.sql
lines = DROP_FILE.read_text(encoding="utf-8").splitlines(keepends=True)
output: list[str] = []
inserted: set[int] = set()

for line in lines:
    # Fix Leech King zone 198 ruby rate from 5% to 1%
    if "VALUES (1505,0,0,1000,1125,@RARE)" in line:
        line = line.replace("@RARE", "@VRARE").replace("(Rare, 5%)", "(Very Rare, 1%)")

    output.append(line)
    m = re.match(r"INSERT INTO `mob_droplist` VALUES \((\d+),", line)
    if m:
        did = int(m.group(1))
        if did in missing and did not in inserted:
            output.append(RUBY_LINE.format(dropid=did))
            inserted.add(did)

still_missing = set(missing) - inserted
if still_missing:
    print(f"Appending new blocks for dropIds: {sorted(still_missing)}")

# Append before footer unlock keys
footer_idx = next(
    (i for i, line in enumerate(output) if "ALTER TABLE `mob_droplist` ENABLE KEYS" in line),
    len(output),
)
append_lines = []
if ZERO_DROPID not in has_ruby:
    append_lines.append("\n-- Shared leech Carbuncle's Ruby droplist (dropId 0 leeches)\n")
    append_lines.append(RUBY_LINE.format(dropid=ZERO_DROPID))
for did in sorted(still_missing):
    append_lines.append(RUBY_LINE.format(dropid=did))

output[footer_idx:footer_idx] = append_lines
DROP_FILE.write_text("".join(output), encoding="utf-8")

# Patch mob_groups: set dropId 0 leeches to ZERO_DROPID
leech_pool_ids = set(pools)
groups_text = GROUPS_FILE.read_text(encoding="utf-8")
updated = 0

def patch_zero_dropid(match: re.Match) -> str:
    global updated
    groupid, poolid, zoneid, name, respawn, spawntype = match.groups()
    if int(poolid) not in leech_pool_ids:
        return match.group(0)
    updated += 1
    return (
        f"INSERT INTO `mob_groups` VALUES ({groupid},{poolid},{zoneid},'{name}',"
        f"{respawn},{spawntype},{ZERO_DROPID},"
    )

groups_text = re.sub(
    r"INSERT INTO `mob_groups` VALUES \((\d+),(\d+),(\d+),'([^']+)',(\d+),(\d+),0,",
    patch_zero_dropid,
    groups_text,
)
GROUPS_FILE.write_text(groups_text, encoding="utf-8")
print(f"Updated {updated} mob_groups entries from dropId 0 -> {ZERO_DROPID}")
print("Done.")
