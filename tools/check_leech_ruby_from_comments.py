#!/usr/bin/env python3
"""Find leech droplists from mob_droplist comments missing Carbuncle's Ruby."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DROP_FILE = ROOT / "sql/mob_droplist.sql"

LEECH_RE = re.compile(r"Leech", re.I)
EXCLUDE_RE = re.compile(r"Goblin\s+Leecher|Leechkeeper", re.I)
INSERT_RE = re.compile(r"INSERT INTO `mob_droplist` VALUES \((\d+),")
RUBY_RE = re.compile(r",1125,@")

# dropId -> set of mob names from comments
leech_dropids: dict[int, set[str]] = {}
has_ruby: set[int] = set()

current_mobs: set[str] = set()
with open(DROP_FILE, encoding="utf-8") as f:
    for line in f:
        if line.startswith("-- ZoneID:"):
            if LEECH_RE.search(line) and not EXCLUDE_RE.search(line):
                mob = line.split(" - ", 1)[1].strip()
                current_mobs.add(mob)
            continue
        if line.startswith("-- ") and not line.startswith("-- ZoneID:"):
            current_mobs = set()
            continue

        m = INSERT_RE.match(line)
        if not m:
            continue
        did = int(m.group(1))
        if RUBY_RE.search(line):
            has_ruby.add(did)
        if current_mobs:
            leech_dropids.setdefault(did, set()).update(current_mobs)

missing = {did: mobs for did, mobs in sorted(leech_dropids.items()) if did not in has_ruby}

print(f"Leech dropids from comments: {len(leech_dropids)}")
print(f"With ruby: {len([d for d in leech_dropids if d in has_ruby])}")
print(f"Missing ruby ({len(missing)}):")
for did, mobs in sorted(missing.items()):
    print(f"  dropId {did}: {sorted(mobs)}")
