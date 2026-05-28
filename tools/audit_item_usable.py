#!/usr/bin/env python3
"""Find item_basic rows typed as Usable (5) missing from item_usable."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

usable_ids: set[int] = set()
with open(ROOT / "sql/item_usable.sql", encoding="utf-8", errors="ignore") as f:
    for line in f:
        m = re.match(r"INSERT INTO `item_usable` VALUES \((\d+),", line)
        if m:
            usable_ids.add(int(m.group(1)))

TYPE_VARS = {
    "@GENERAL_TYPE": 1,
    "@LINKSHELL_TYPE": 2,
    "@FURNISHING_TYPE": 3,
    "@PUPPET_TYPE": 4,
    "@USABLE_TYPE": 5,
    "@EQUIPMENT_TYPE": 6,
    "@WEAPON_TYPE": 7,
    "@CURRENCY_TYPE": 8,
}


def resolve_type(token: str) -> int | None:
    token = token.strip()
    if token in TYPE_VARS:
        return TYPE_VARS[token]
    try:
        return int(token)
    except ValueError:
        return None

missing: list[tuple[int, str]] = []
with open(ROOT / "sql/item_basic.sql", encoding="utf-8", errors="ignore") as f:
    for line in f:
        m = re.match(r"INSERT INTO `item_basic` VALUES \((\d+),[^,]*,'([^']*)'", line)
        if not m:
            continue
        itemid = int(m.group(1))
        name = m.group(2)
        # type is the 6th field: itemid, subid, name, sortname, name_jp, type
        parts = line.split("VALUES (", 1)[1].rstrip(");\n")
        fields = []
        cur = ""
        in_quote = False
        for ch in parts:
            if ch == "'":
                in_quote = not in_quote
                cur += ch
            elif ch == "," and not in_quote:
                fields.append(cur.strip())
                cur = ""
            else:
                cur += ch
        if cur:
            fields.append(cur.strip())
        if len(fields) < 6:
            continue
        typ = resolve_type(fields[5])
        if typ is None:
            continue
        if typ == 5 and itemid not in usable_ids:
            missing.append((itemid, name))

print(f"item_usable rows: {len(usable_ids)}")
print(f"item_basic type=5 missing from item_usable: {len(missing)}")
for itemid, name in missing[:50]:
    print(f"  {itemid}: {name}")
if len(missing) > 50:
    print(f"  ... and {len(missing) - 50} more")
