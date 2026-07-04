#!/usr/bin/env python3
"""Fix mob_pools.speciesid for South Gustaberg (zone 107) mobs.

Local mob_pools had speciesid swapped with resist_id-style values, breaking
crystal drops and family stats. Values are taken from upstream LandSandBoat.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOB_POOLS = ROOT / "sql" / "mob_pools.sql"
ZONE_ID = 107

# poolid -> correct speciesid (upstream/base mob_pools.sql)
SPECIES_FIXES: dict[int, int] = {
    103: 150,   # Amber_Quadav
    107: 150,   # Amethyst_Quadav
    441: 409,   # Black_Wolf
    551: 25,    # Bubbly_Bernie
    579: 111,   # Bull_[Herd1]
    580: 111,   # Bull_[Herd2]
    581: 111,   # Bull_[Herd3]
    611: 111,   # Calf_[Herd1]
    612: 111,   # Calf_[Herd2]
    613: 111,   # Calf_[Herd3]
    645: 111,   # Carnero
    821: 111,   # Cow_[Herd1]
    822: 111,   # Cow_[Herd2]
    823: 111,   # Cow_[Herd3]
    1038: 181,  # Ding_Bats
    1214: 419,  # Enchanted_Bones_blm
    6543: 419,  # Enchanted_Bones_war
    1364: 173,  # Fledermaus
    1648: 126,  # Goblin_Digger
    1659: 124,  # Goblin_Fisher
    1737: 126,  # Goblin_Thug
    1744: 126,  # Goblin_Weaver
    1829: 307,  # Grylio
    2000: 428,  # Huge_Hornet
    2372: 25,   # Land_Crab
    2384: 307,  # Leaping_Lizzy
    2547: 428,  # Maneating_Hornet
    2722: 25,   # Mole_Crab
    3058: 111,  # Ornery_Sheep
    3102: 25,   # Passage_Crab
    3148: 274,  # Pixie
    3241: 195,  # Pyracmon
    3381: 307,  # Rock_Lizard
    3452: 25,   # Sand_Crab
    3611: 46,   # Shrapnel
    3779: 25,   # Stone_Crab
    3780: 23,   # Stone_Eater
    4053: 23,   # Tunnel_Worm
    4266: 175,  # Vulture
    4277: 360,  # Walking_Sapling
    4381: 173,  # Wraith_Bat
    4477: 150,  # Young_Quadav
    4688: 274,  # Bhishani
    5419: 175,  # Tococo
    6771: 25,   # Land_Crab_fished
    6830: 307,  # Bounding_Belinda
}


def parse_values(raw: str) -> list[str]:
    parts: list[str] = []
    cur = ""
    in_q = False
    for ch in raw:
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


def format_values(parts: list[str]) -> str:
    return ",".join(parts)


def fix_mob_pools() -> int:
    text = MOB_POOLS.read_text(encoding="utf-8", errors="replace")
    pattern = re.compile(r"INSERT INTO `mob_pools` VALUES \((.+?)\);", re.DOTALL)
    changed = 0

    def repl(match: re.Match[str]) -> str:
        nonlocal changed
        parts = parse_values(match.group(1))
        poolid = int(parts[0])
        if poolid not in SPECIES_FIXES:
            return match.group(0)

        new_species = SPECIES_FIXES[poolid]
        old_species = int(parts[3])
        if old_species == new_species:
            return match.group(0)

        parts[3] = str(new_species)
        changed += 1
        return f"INSERT INTO `mob_pools` VALUES ({format_values(parts)});"

    new_text = pattern.sub(repl, text)
    if changed:
        MOB_POOLS.write_text(new_text, encoding="utf-8")
    return changed


def apply_db() -> None:
    for poolid, speciesid in sorted(SPECIES_FIXES.items()):
        sql = f"UPDATE mob_pools SET speciesid = {speciesid} WHERE poolid = {poolid};"
        subprocess.run(
            [
                "mysql",
                "-h",
                "127.0.0.1",
                "-u",
                "root",
                "-pFr0styP1n3!",
                "xidb",
                "-e",
                sql,
            ],
            check=True,
            capture_output=True,
            text=True,
        )


def main() -> int:
    changed = fix_mob_pools()
    print(f"Updated speciesid on {changed} mob_pools rows in {MOB_POOLS}")
    apply_db()
    print(f"Applied {len(SPECIES_FIXES)} speciesid fixes to database (zone {ZONE_ID})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
