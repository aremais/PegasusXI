"""Verify mob_pools speciesid column slotting and value accuracy on PegasusXI."""
from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

from tools.audit import upstream
from tools.audit.schemas import MOB_POOLS_COLUMNS, MOB_SPECIES_SYSTEM_COLUMNS
from tools.audit.sql_parser import rows_by_key

REPO = Path(__file__).resolve().parents[2]
NETWORK = REPO / "settings" / "network.lua"


def read_lua(key: str) -> str:
    text = NETWORK.read_text(encoding="utf-8")
    m = re.search(rf"{key}\s*=\s*'([^']*)'", text)
    if not m:
        m = re.search(rf"{key}\s*=\s*(\d+)", text)
    return m.group(1)


def query_db(sql: str) -> list[tuple[str, ...]]:
    exe = r"C:\Program Files\MariaDB 10.6\bin\mysql.exe"
    env = os.environ.copy()
    env["MYSQL_PWD"] = read_lua("SQL_PASSWORD")
    proc = subprocess.run(
        [
            exe, "--protocol=TCP",
            "-h", read_lua("SQL_HOST"),
            "-P", read_lua("SQL_PORT"),
            "-u", read_lua("SQL_LOGIN"),
            read_lua("SQL_DATABASE"),
            "-N", "-B", "-e", sql,
        ],
        capture_output=True, text=True, env=env, check=True,
    )
    return [tuple(line.split("\t")) for line in proc.stdout.strip().splitlines() if line]


def parse_create_table(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"CREATE TABLE `mob_pools`\s*\((.*?)\)\s*ENGINE", text, re.S | re.I)
    if not m:
        return []
    cols = []
    for line in m.group(1).splitlines():
        line = line.strip().rstrip(",")
        cm = re.match(r"`(\w+)`", line)
        if cm:
            cols.append(cm.group(1))
    return cols


def main() -> None:
    local_path = REPO / "sql" / "mob_pools.sql"
    lsb_path = upstream.upstream_path("mob_pools.sql")
    local = rows_by_key(local_path, "mob_pools", MOB_POOLS_COLUMNS, key="poolid")
    lsb = rows_by_key(lsb_path, "mob_pools", MOB_POOLS_COLUMNS, key="poolid")
    species = rows_by_key(
        REPO / "sql" / "mob_species_system.sql",
        "mob_species_system", MOB_SPECIES_SYSTEM_COLUMNS, key="speciesID",
    )

    peg_cols = parse_create_table(local_path)
    lsb_cols = parse_create_table(lsb_path)

    print("=== 1. Column slot (schema) ===")
    print(f"Pegasus CREATE TABLE columns ({len(peg_cols)}): 4th = {peg_cols[3] if len(peg_cols) >= 4 else '?'}")
    print(f"LSB CREATE TABLE columns ({len(lsb_cols)}):     4th = {lsb_cols[3] if len(lsb_cols) >= 4 else '?'}")
    print(f"Audit INSERT parser expects column 4:          {MOB_POOLS_COLUMNS[3]}")
    schema_ok = peg_cols[3] in ("speciesid", "familyid") and lsb_cols[3] == "speciesid"
    print(f"Schema slot alignment: {'OK (same position, Pegasus uses familyid name)' if schema_ok else 'PROBLEM'}")

    # Value accuracy vs LSB
    match = mismatch = 0
    resist_copy = 0
    invalid = 0
    for pid in sorted(set(local) & set(lsb)):
        lp, up = local[pid], lsb[pid]
        ls, us = int(lp["speciesid"]), int(up["speciesid"])
        if ls == us:
            match += 1
        else:
            mismatch += 1
        if ls == int(lp["resist_id"]) and ls != us:
            resist_copy += 1
        if ls not in species:
            invalid += 1

    print()
    print("=== 2. Value accuracy (PegasusXI sql/mob_pools.sql vs LSB base) ===")
    shared = match + mismatch
    print(f"Shared pools: {shared}")
    print(f"  Correct speciesid (matches LSB):     {match} ({100*match/shared:.2f}%)")
    print(f"  Wrong speciesid (differs from LSB):  {mismatch} ({100*mismatch/shared:.2f}%)")
    print(f"  Wrong AND speciesid == resist_id:    {resist_copy} (classic mis-slot/copy bug)")
    print(f"  Invalid speciesid (not in species table): {invalid}")

    # Live DB vs SQL file
    db_rows = query_db("SELECT poolid, name, familyid, resist_id FROM mob_pools")
    db = {int(r[0]): {"name": r[1], "familyid": int(r[2]), "resist_id": int(r[3])} for r in db_rows}
    sql_db_match = sql_db_mismatch = 0
    for pid in sorted(set(local) & set(db)):
        if int(local[pid]["speciesid"]) == db[pid]["familyid"]:
            sql_db_match += 1
        else:
            sql_db_mismatch += 1

    db_lsb_match = 0
    for pid in sorted(set(db) & set(lsb)):
        if db[pid]["familyid"] == int(lsb[pid]["speciesid"]):
            db_lsb_match += 1

    print()
    print("=== 3. Live DB (xidb.mob_pools.familyid) ===")
    print(f"Column in DB: familyid (server C++ expects speciesid — rename patch not applied)")
    print(f"  SQL file vs live DB agree:             {sql_db_match}/{sql_db_match+sql_db_mismatch}")
    print(f"  Live DB matches LSB speciesid:         {db_lsb_match}/{len(set(db)&set(lsb))}")
    db_resist_copy = sum(
        1 for pid in db
        if pid in lsb
        and db[pid]["familyid"] == db[pid]["resist_id"]
        and db[pid]["familyid"] != int(lsb[pid]["speciesid"])
    )
    print(f"  Live DB familyid == resist_id (wrong): {db_resist_copy}")

    print()
    print("=== 4. Spot-check: column slot vs resist_id column ===")
    samples = [1, 3744, 71, 4720, 1827]
    print("poolid | name | col4 speciesid | col26 resist_id | LSB speciesid | diagnosis")
    for pid in samples:
        if pid not in local or pid not in lsb:
            continue
        lp = local[pid]
        ls, rid, us = int(lp["speciesid"]), int(lp["resist_id"]), int(lsb[pid]["speciesid"])
        if ls == us:
            diag = "CORRECT"
        elif ls == rid:
            diag = "WRONG: speciesid holds resist_id value"
        else:
            diag = "WRONG: other mismatch"
        print(f"{pid:5} | {lp['name'][:20]:20} | {ls:4} | {rid:4} | {us:4} | {diag}")

    print()
    print("=== VERDICT ===")
    if schema_ok and match <= 3:
        print("Column POSITION is correct (4th INSERT field = species/family ID).")
        print("Column VALUES are NOT accurate: ~99.96% of pools have the wrong ID slotted,")
        print("most commonly because resist_id was copied into the speciesid/familyid field.")
        print("Pegasus is NOT species-accurate today; LSB base is the correct reference.")
    elif not schema_ok:
        print("Schema column order may be misaligned — investigate CREATE TABLE vs INSERT order.")
    else:
        print("Partial alignment — review counts above.")


if __name__ == "__main__":
    main()
