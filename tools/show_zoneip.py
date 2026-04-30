#!/usr/bin/env python3
"""
Print zoneip (and sample zoneport) from xidb.zone_settings using SQL_* from settings/network.lua.
Requires: pip install mariadb   (see tools/requirements.txt)
No mysql.exe client needed.
"""

from __future__ import annotations

import os
import sys


def _server_root() -> str:
    return os.path.normpath(os.path.realpath(os.path.join(os.path.dirname(__file__), "..")))


def _from_server_path(path: str) -> str:
    return os.path.normpath(os.path.join(_server_root(), path))


def _load_lua_settings() -> dict:
    settings: dict = {}

    def load_into_dict(filename: str, target: dict) -> None:
        if not os.path.isfile(filename):
            return
        filename_key = os.path.basename(filename)[:-4]
        current = target.get(filename_key, {})
        with open(filename, encoding="utf-8", errors="replace") as handle:
            for line in handle:
                if not line or "=" not in line:
                    continue
                line = line.replace("\n", "")
                parts = line.split("=", 1)
                key = parts[0].strip()
                val = parts[1].strip()
                if key.startswith("--"):
                    continue
                val = val.rsplit("--")[0].strip()
                if val.startswith('"'):
                    val = val[1:]
                elif val.startswith("'"):
                    val = val[1:]
                if val.endswith(","):
                    val = val[:-1]
                if val.endswith('"'):
                    val = val[:-1]
                elif val.endswith("'"):
                    val = val[:-1]
                current[key] = val
        target[filename_key] = current

    default_dir = _from_server_path("settings/default")
    for name in os.listdir(default_dir):
        if name.endswith(".lua"):
            load_into_dict(os.path.join(default_dir, name), settings)

    settings_dir = _from_server_path("settings")
    for name in os.listdir(settings_dir):
        if name.endswith(".lua"):
            load_into_dict(os.path.join(settings_dir, name), settings)

    return settings


def main() -> int:
    try:
        import mariadb
    except ImportError:
        print("Missing Python package 'mariadb'. From the server repo root run:", file=sys.stderr)
        print("  python -m pip install -r tools/requirements.txt", file=sys.stderr)
        return 1

    settings = _load_lua_settings()
    net = settings.get("network", {})
    host = os.getenv("XI_NETWORK_SQL_HOST") or net.get("SQL_HOST", "127.0.0.1")
    port = int(os.getenv("XI_NETWORK_SQL_PORT") or net.get("SQL_PORT", "3306"))
    login = os.getenv("XI_NETWORK_SQL_LOGIN") or net.get("SQL_LOGIN", "root")
    password = os.getenv("XI_NETWORK_SQL_PASSWORD") or net.get("SQL_PASSWORD", "")
    database = os.getenv("XI_NETWORK_SQL_DATABASE") or net.get("SQL_DATABASE", "xidb")

    try:
        conn = mariadb.connect(host=host, user=login, passwd=password, db=database, port=port)
    except mariadb.Error as err:
        print(f"Database connection failed: {err}", file=sys.stderr)
        return 1

    try:
        cur = conn.cursor()
        cur.execute("SELECT DISTINCT zoneip FROM zone_settings ORDER BY zoneip")
        rows = cur.fetchall()
        print("Distinct zoneip values:")
        for (zoneip,) in rows:
            print(f"  {zoneip}")
        cur.execute(
            "SELECT zoneid, `name`, zoneip, zoneport FROM zone_settings ORDER BY zoneid LIMIT 15"
        )
        print("\nFirst 15 zones (zoneid, name, zoneip, zoneport):")
        for row in cur.fetchall():
            print(f"  {row[0]}\t{row[1]}\t{row[2]}\t{row[3]}")
    finally:
        conn.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
