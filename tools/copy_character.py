#!/usr/bin/env python3
"""
Copy all character game data from one charid to another.

Preserves the destination charid and charname. Both characters must be offline.
Usage: python tools/copy_character.py <source_charid> <dest_charid> [--dry-run]
"""

from __future__ import annotations

import argparse
import subprocess
import sys

# Tables with a charid column that hold per-character game state.
# Excludes session/login/audit tables.
CHAR_TABLES = [
    "char_chocobos",
    "char_effects",
    "char_equip",
    "char_equip_saved",
    "char_exp",
    "char_fishing_contest_history",
    "char_flags",
    "char_history",
    "char_inventory",
    "char_jobs",
    "char_job_points",
    "char_look",
    "char_merit",
    "char_monstrosity",
    "char_pet",
    "char_points",
    "char_profile",
    "char_recast",
    "char_skills",
    "char_spells",
    "char_stats",
    "char_storage",
    "char_style",
    "char_unlocks",
    "char_vars",
    "delivery_box",
]

CHARS_COPY_COLUMNS = [
    "accid",
    "original_accid",
    "nation",
    "pos_zone",
    "pos_prevzone",
    "pos_prevzonelineid",
    "pos_rot",
    "pos_x",
    "pos_y",
    "pos_z",
    "moghouse",
    "boundary",
    "home_zone",
    "home_rot",
    "home_x",
    "home_y",
    "home_z",
    "missions",
    "assault",
    "campaign",
    "eminence",
    "quests",
    "keyitems",
    "set_blue_spells",
    "abilities",
    "weaponskills",
    "titles",
    "zones",
    "playtime",
    "unlocked_weapons",
    "gmlevel",
    "languages",
    "mentor",
    "job_master",
    "campaign_allegiance",
    "isstylelocked",
    "settings",
    "chatfilters_1",
    "chatfilters_2",
    "moghancement",
]


def run_mysql(sql: str, password: str, database: str = "xidb", host: str = "127.0.0.1", user: str = "root") -> str:
    result = subprocess.run(
        ["mysql", f"-h{host}", f"-u{user}", f"-p{password}", database, "-N", "-e", sql],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout.strip()


def get_columns(table: str, password: str) -> list[str]:
    out = run_mysql(
        f"SELECT COLUMN_NAME FROM information_schema.COLUMNS "
        f"WHERE TABLE_SCHEMA = 'xidb' AND TABLE_NAME = '{table}' ORDER BY ORDINAL_POSITION",
        password,
    )
    return out.splitlines() if out else []


def main() -> int:
    parser = argparse.ArgumentParser(description="Copy character data between charids")
    parser.add_argument("source", type=int, help="Source charid")
    parser.add_argument("dest", type=int, help="Destination charid")
    parser.add_argument("--password", default="Fr0styP1n3!", help="MySQL password")
    parser.add_argument("--dry-run", action="store_true", help="Print SQL only")
    args = parser.parse_args()

    src, dst = args.source, args.dest
    pw = args.password

    if src == dst:
        print("Source and destination charid must differ.", file=sys.stderr)
        return 1

    names = run_mysql(
        f"SELECT charid, charname FROM chars WHERE charid IN ({src}, {dst}) ORDER BY charid",
        pw,
    )
    rows = [line.split("\t") for line in names.splitlines() if line.strip()]
    if len(rows) != 2:
        print(f"Expected both charids {src} and {dst} in chars table; found: {names!r}", file=sys.stderr)
        return 1

    dest_name = next(r[1] for r in rows if int(r[0]) == dst)

    sessions = run_mysql(f"SELECT COUNT(*) FROM accounts_sessions WHERE charid IN ({src}, {dst})", pw)
    if sessions != "0":
        print("One or both characters are logged in. Log them out before copying.", file=sys.stderr)
        return 1

    statements: list[str] = [
        "SET FOREIGN_KEY_CHECKS=0;",
        "START TRANSACTION;",
    ]

    for table in CHAR_TABLES:
        cols = get_columns(table, pw)
        if not cols or "charid" not in cols:
            continue

        other_cols = [c for c in cols if c != "charid"]
        select_cols = ", ".join(
            f"'{dest_name}'" if c == "charname" else f"`{c}`" for c in other_cols
        )
        insert_cols = ", ".join(["charid"] + [f"`{c}`" for c in other_cols])

        statements.append(f"DELETE FROM `{table}` WHERE charid = {dst};")
        if other_cols:
            statements.append(
                f"INSERT INTO `{table}` ({insert_cols}) "
                f"SELECT {dst}, {select_cols} FROM `{table}` WHERE charid = {src};"
            )

    set_clause = ", ".join(f"h.`{c}` = m.`{c}`" for c in CHARS_COPY_COLUMNS)
    statements.append(
        f"UPDATE chars h JOIN chars m ON m.charid = {src} SET {set_clause} WHERE h.charid = {dst};"
    )
    statements.append("DELETE FROM accounts_parties WHERE charid = {dst};".format(dst=dst))
    statements.append("COMMIT;")
    statements.append("SET FOREIGN_KEY_CHECKS=1;")

    sql = "\n".join(statements)

    if args.dry_run:
        print(sql)
        return 0

    run_mysql(sql, pw)

    summary = run_mysql(
        f"SELECT "
        f"(SELECT charname FROM chars WHERE charid={src}), "
        f"(SELECT charname FROM chars WHERE charid={dst}), "
        f"(SELECT mjob FROM char_stats WHERE charid={dst}), "
        f"(SELECT mlvl FROM char_stats WHERE charid={dst}), "
        f"(SELECT COUNT(*) FROM char_inventory WHERE charid={dst}), "
        f"(SELECT COUNT(*) FROM char_vars WHERE charid={dst})",
        pw,
    )
    parts = summary.split("\t")
    print(f"Copied {parts[0]} (charid {src}) -> {parts[1]} (charid {dst})")
    print(f"  Main job/level: {parts[2]}/{parts[3]}")
    print(f"  Inventory rows: {parts[4]}")
    print(f"  Char vars:      {parts[5]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
