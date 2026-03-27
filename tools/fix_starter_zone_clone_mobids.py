#!/usr/bin/env python3
"""
Re-create starter-zone mob spawn clones using valid mob targid ranges.

FFXI / LandSandBoat entity lookup treats targid 0x400-0x6FF as PCs only.
Mobs must use targid < 0x400 OR 0x700-0xFFF.  Simple +1000/+2000 mobid offsets
often land in the PC-only band (1024-1791), breaking combat/XP/stats.

This script:
1) Deletes rows that are exact +1000 / +2000 duplicates of another row.
2) Inserts two valid-ID clones per remaining row in the target zones (3x total vs base).
"""

from __future__ import annotations

import argparse
import os
import sys
from collections import defaultdict

import pymysql

ZONES = (100, 101, 106, 107, 115, 116)


def valid_targid(t: int) -> bool:
    return t < 0x400 or t >= 0x700


def alloc_targid(used: set[int]) -> int:
    # Prefer high mob indices to avoid colliding with retail low IDs.
    for t in range(4094, 0x700 - 1, -1):
        if valid_targid(t) and t not in used:
            used.add(t)
            return t
    for t in range(0x3FF, -1, -1):
        if t not in used:
            used.add(t)
            return t
    raise RuntimeError("No free targid slots in zone (4096 exhausted)")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--host", default=os.environ.get("XI_SQL_HOST", "127.0.0.1"))
    p.add_argument("--port", type=int, default=int(os.environ.get("XI_SQL_PORT", "3306")))
    p.add_argument("--user", default=os.environ.get("XI_SQL_LOGIN", "root"))
    p.add_argument("--password", default=os.environ.get("XI_SQL_PASSWORD", ""))
    p.add_argument("--database", default=os.environ.get("XI_SQL_DATABASE", "xidb"))
    args = p.parse_args()

    if not args.password:
        print("Set XI_SQL_PASSWORD or pass --password", file=sys.stderr)
        return 2

    conn = pymysql.connect(
        host=args.host,
        port=args.port,
        user=args.user,
        password=args.password,
        database=args.database,
        autocommit=False,
        cursorclass=pymysql.cursors.DictCursor,
    )

    try:
        with conn.cursor() as cur:
            zone_list = ",".join(str(z) for z in ZONES)

            # 1) Remove broken duplicate rows from old +1000 / +2000 inserts.
            #    (Do not match on floats — tiny drift breaks the join.)
            cur.execute(
                f"""
                DELETE FROM mob_spawn_points
                WHERE mobid IN (
                    SELECT mobid FROM (
                        SELECT m.mobid
                        FROM mob_spawn_points m
                        INNER JOIN mob_spawn_points b
                            ON b.mobid = m.mobid - 1000
                           AND ((b.mobid >> 12) & 4095) = ((m.mobid >> 12) & 4095)
                        WHERE ((m.mobid >> 12) & 4095) IN ({zone_list})
                        UNION
                        SELECT m.mobid
                        FROM mob_spawn_points m
                        INNER JOIN mob_spawn_points b
                            ON b.mobid = m.mobid - 2000
                           AND ((b.mobid >> 12) & 4095) = ((m.mobid >> 12) & 4095)
                        WHERE ((m.mobid >> 12) & 4095) IN ({zone_list})
                    ) doomed
                )
                """
            )
            print(f"Deleted old clone rows: {cur.rowcount}")

            # 2) Load remaining spawns in those zones.
            cur.execute(
                f"""
                SELECT mobid, spawnslotid, mobname, polutils_name, groupid,
                       minLevel, maxLevel, pos_x, pos_y, pos_z, pos_rot
                FROM mob_spawn_points
                WHERE ((mobid >> 12) & 4095) IN ({zone_list})
                ORDER BY mobid
                """
            )
            rows = cur.fetchall()

            used_by_zone: dict[int, set[int]] = defaultdict(set)
            cur.execute(
                f"""
                SELECT ((mobid >> 12) & 4095) AS zoneid, (mobid & 4095) AS tid
                FROM mob_spawn_points
                WHERE ((mobid >> 12) & 4095) IN ({zone_list})
                """
            )
            for r in cur.fetchall():
                used_by_zone[int(r["zoneid"])].add(int(r["tid"]))

            inserts = []
            for r in rows:
                zone = (int(r["mobid"]) >> 12) & 4095
                base = zone << 12
                used = used_by_zone[zone]
                for _ in range(2):
                    tid = alloc_targid(used)
                    new_mobid = base | tid
                    inserts.append(
                        (
                            new_mobid,
                            int(r["spawnslotid"]),
                            r["mobname"],
                            r["polutils_name"],
                            int(r["groupid"]),
                            int(r["minLevel"]),
                            int(r["maxLevel"]),
                            float(r["pos_x"]),
                            float(r["pos_y"]),
                            float(r["pos_z"]),
                            int(r["pos_rot"]),
                        )
                    )

            if inserts:
                cur.executemany(
                    """
                    INSERT INTO mob_spawn_points
                        (mobid, spawnslotid, mobname, polutils_name, groupid,
                         minLevel, maxLevel, pos_x, pos_y, pos_z, pos_rot)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                    """,
                    inserts,
                )
            print(f"Inserted fresh clone rows: {len(inserts)}")

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    print("Done. Restart xi_map.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
