#!/usr/bin/env python3
"""Apply extended NPC/mob display name column limits to xidb."""

import os
import sys

import mariadb

sys.path.insert(0, os.path.dirname(__file__))
import dbtool  # noqa: E402

dbtool.fetch_credentials()
password = os.getenv("XI_NETWORK_SQL_PASSWORD") or dbtool.password or "Fr0styP1n3!"

STATEMENTS = [
    "ALTER TABLE `mob_pools` MODIFY `packet_name` varchar(32) DEFAULT NULL",
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

    for stmt in STATEMENTS:
        print(f"Running: {stmt}")
        cur.execute(stmt)

    conn.commit()

    cur.execute("SHOW COLUMNS FROM mob_pools LIKE 'packet_name'")
    print("mob_pools.packet_name:", cur.fetchone())

    cur.execute("SHOW COLUMNS FROM npc_list LIKE 'polutils_name'")
    print("npc_list.polutils_name:", cur.fetchone())

    cur.execute("SHOW COLUMNS FROM mob_spawn_points LIKE 'polutils_name'")
    print("mob_spawn_points.polutils_name:", cur.fetchone())

    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
