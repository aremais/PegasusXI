#!/usr/bin/env python3
"""Apply Bastok Markets missing NPC fixes to xidb."""

import os
import sys

import mariadb

# Prefer env / dbtool settings; fall back to known server password.
sys.path.insert(0, os.path.dirname(__file__))
import dbtool  # noqa: E402

dbtool.fetch_credentials()
password = os.getenv("XI_NETWORK_SQL_PASSWORD") or dbtool.password or "Fr0styP1n3!"

STATEMENTS = [
    "INSERT IGNORE INTO npc_list VALUES (17740187,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740191,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740192,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740193,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740194,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740195,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740197,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740204,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740205,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740206,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740207,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740208,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740210,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    "INSERT IGNORE INTO npc_list VALUES (17740211,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0)",
    """INSERT INTO npc_list VALUES (17740209,'Ephemeral_Moogle_Gold','Ephemeral Moogle',221,-219.820,-6.820,-63.250,14,50,50,0,0,128,0,3,0x0000520000000000000000000000000000000000,0,NULL,1)
ON DUPLICATE KEY UPDATE
  name='Ephemeral_Moogle_Gold',
  polutils_name='Ephemeral Moogle',
  pos_rot=221,
  pos_x=-219.820,
  pos_y=-6.820,
  pos_z=-63.250,
  flag=14,
  speed=50,
  speedsub=50,
  animation=0,
  animationsub=0,
  namevis=128,
  status=0,
  entityFlags=3,
  look=0x0000520000000000000000000000000000000000,
  name_prefix=0,
  content_tag=NULL,
  widescan=1""",
    """UPDATE npc_list SET
  name='blank',
  polutils_name='',
  pos_rot=0,
  pos_x=0.000,
  pos_y=0.000,
  pos_z=0.000,
  flag=0,
  speed=50,
  speedsub=50,
  animation=0,
  animationsub=0,
  namevis=0,
  status=2,
  entityFlags=3,
  look=0x0000320000000000000000000000000000000000,
  name_prefix=0,
  content_tag=NULL,
  widescan=0
WHERE npcid=17740224""",
]

NPCIDS = [
    17740187, 17740191, 17740192, 17740193, 17740194, 17740195, 17740197,
    17740204, 17740205, 17740206, 17740207, 17740208, 17740209, 17740210, 17740211,
]


def main() -> int:
    conn = mariadb.connect(
        host=dbtool.host,
        user=dbtool.login,
        password=password,
        database=dbtool.database,
        port=dbtool.port,
    )
    cur = conn.cursor()

    for i, stmt in enumerate(STATEMENTS, 1):
        cur.execute(stmt)
        print(f"[{i}/{len(STATEMENTS)}] OK (affected {cur.rowcount})")

    conn.commit()

    placeholders = ",".join("?" * len(NPCIDS))
    cur.execute(
        f"SELECT npcid, name, polutils_name FROM npc_list WHERE npcid IN ({placeholders}) ORDER BY npcid",
        NPCIDS,
    )
    rows = cur.fetchall()
    print(f"\nVerified {len(rows)}/{len(NPCIDS)} NPC rows:")
    for row in rows:
        print(f"  {row[0]}: {row[1].decode() if isinstance(row[1], bytes) else row[1]}")

    missing = set(NPCIDS) - {r[0] for r in rows}
    if missing:
        print("Missing:", sorted(missing))
        return 1

    print("All Bastok Markets NPC fixes applied.")
    cur.close()
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
