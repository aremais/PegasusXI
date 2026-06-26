#!/usr/bin/env python3
"""Align regular toad mob_pools with LSB (speciesid 32, correct links/skills)."""

import os
import sys

import mariadb

sys.path.insert(0, os.path.dirname(__file__))
import dbtool  # noqa: E402

dbtool.fetch_credentials()
password = os.getenv("XI_NETWORK_SQL_PASSWORD") or dbtool.password or "Fr0styP1n3!"

# poolid -> (speciesid, links, skill_list_id)
TOAD_POOLS = {
    3934: (32, 0, 196),
    4989: (32, 0, 196),
    5037: (32, 0, 196),
    5038: (32, 0, 196),
    5093: (32, 0, 196),
    5399: (32, 0, 196),
    6378: (32, 0, 196),
}


def main() -> int:
    conn = mariadb.connect(
        host=dbtool.host,
        user=dbtool.login,
        password=password,
        database=dbtool.database,
        port=dbtool.port,
    )
    cur = conn.cursor()

    updated = 0
    for poolid, (speciesid, links, skill_list_id) in TOAD_POOLS.items():
        cur.execute(
            "UPDATE mob_pools SET speciesid = ?, links = ?, skill_list_id = ? "
            "WHERE poolid = ?",
            (speciesid, links, skill_list_id, poolid),
        )
        if cur.rowcount:
            updated += 1
            print(f"Updated pool {poolid}: speciesid={speciesid}, links={links}, skill_list_id={skill_list_id}")
        else:
            print(f"WARNING: pool {poolid} not found")

    conn.commit()

    print("\nVerification:")
    placeholders = ",".join("?" * len(TOAD_POOLS))
    cur.execute(
        f"SELECT poolid, name, speciesid, aggro, links, skill_list_id "
        f"FROM mob_pools WHERE poolid IN ({placeholders}) ORDER BY poolid",
        tuple(TOAD_POOLS.keys()),
    )
    ok = True
    for row in cur.fetchall():
        poolid, name, speciesid, aggro, links, skill_list_id = row
        expected = TOAD_POOLS[poolid]
        if (speciesid, links, skill_list_id) != expected:
            ok = False
            print(f"  FAIL {poolid} {name}: got ({speciesid},{links},{skill_list_id}), expected {expected}")
        else:
            print(f"  OK   {poolid} {name}: speciesid={speciesid}, links={links}, skill_list_id={skill_list_id}, aggro={aggro}")

    cur.execute(
        "SELECT mg.name, mp.speciesid, mp.links, mss.familyID, mss.detects "
        "FROM mob_groups mg "
        "JOIN mob_pools mp ON mg.poolid = mp.poolid "
        "JOIN mob_species_system mss ON mp.speciesid = mss.speciesid "
        "WHERE mg.zoneid = 273 AND mg.name LIKE '%Toad%' AND mg.poolid != 0"
    )
    print("\nWoh Gates toads (post-fix):")
    for row in cur.fetchall():
        print(f"  {row}")

    conn.close()
    print(f"\nUpdated {updated}/{len(TOAD_POOLS)} pools.")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
