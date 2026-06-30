#!/usr/bin/env python3
"""Compare jug Ready moves: SQL vs pets/*.lua vs mobskills/*.lua (with alias detection)."""
import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql"
PETS = ROOT / "scripts" / "actions" / "abilities" / "pets"
MOB = ROOT / "scripts" / "actions" / "mobskills"

list_names = {}
skill_lists = defaultdict(list)
for line in (SQL / "mob_skill_lists.sql").read_text(encoding="utf-8").splitlines():
    m = re.match(r"INSERT INTO `mob_skill_lists` VALUES \('([^']+)',(\d+),(\d+)\)", line)
    if m and m.group(1).startswith("Jug_"):
        list_names[int(m.group(2))] = m.group(1)
        skill_lists[int(m.group(2))].append(int(m.group(3)))

pet_skills = {}
for line in (SQL / "pet_skills.sql").read_text(encoding="utf-8").splitlines():
    m = re.match(r"INSERT INTO `pet_skills` VALUES \((\d+),\d+,\d+,'([^']+)'", line)
    if m:
        pet_skills[int(m.group(1))] = m.group(2)

jug_ids = sorted({x for ids in skill_lists.values() for x in ids})
mob_files = {p.stem for p in MOB.glob("*.lua")}

def mobskill_for_pet_lua(name: str) -> str | None:
    path = PETS / f"{name}.lua"
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"local skillName = '([^']+)'", text)
    return m.group(1) if m else name

rows = []
for psid in jug_ids:
    name = pet_skills.get(psid, "?")
    pet_lua = (PETS / f"{name}.lua").exists() if name != "?" else False
    mob_target = mobskill_for_pet_lua(name) if pet_lua else None
    mob_ok = mob_target in mob_files if mob_target else False
    rows.append(
        {
            "id": psid,
            "name": name,
            "pet_lua": pet_lua,
            "mob_target": mob_target,
            "mob_ok": mob_ok,
        }
    )

missing_pet = [r for r in rows if not r["pet_lua"]]
broken_chain = [r for r in rows if r["pet_lua"] and not r["mob_ok"]]
ok = [r for r in rows if r["pet_lua"] and r["mob_ok"]]

print(f"Jug Ready moves in SQL: {len(rows)}")
print(f"Complete chain (pets/*.lua -> mobskills/*.lua): {len(ok)}")
print(f"Missing pets/*.lua: {len(missing_pet)}")
print(f"pets/*.lua present but mobskill target missing: {len(broken_chain)}")
print()

if missing_pet:
    print("Missing pets/*.lua:")
    for r in missing_pet:
        mob_direct = r["name"] in mob_files
        note = "mobskill exists" if mob_direct else "no mobskill"
        print(f"  {r['id']:4} {r['name']:24} ({note})")
    print()

if broken_chain:
    print("Broken mobskill reference in pets/*.lua:")
    for r in broken_chain:
        print(f"  {r['id']:4} {r['name']:24} -> {r['mob_target']}")
    print()

# families
missing_ids = {r["id"] for r in missing_pet + broken_chain}
if missing_ids:
    print("Affected jug families:")
    for lid in sorted(skill_lists):
        hits = [pet_skills[i] for i in skill_lists[lid] if i in missing_ids]
        if hits:
            print(f"  {list_names[lid]}: {', '.join(hits)}")
