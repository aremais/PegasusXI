#!/usr/bin/env python3
"""Set zone_settings.zoneip to this host's public IPv4 for all rows with zoneport > 0.

Optional: --single-map sets every zoneport > 0 to 54230 when you only run one xi_map.

Reads SQL_* from settings/network.lua (same merge as dbtool: default + settings/).
Requires: mysql client on PATH or set MYSQL_BIN dir; urllib for ipify.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

SERVER_ROOT = Path(__file__).resolve().parents[1]


def parse_lua_network() -> dict[str, str]:
    merged: dict[str, str] = {}
    for sub in ("settings/default/network.lua", "settings/network.lua"):
        p = SERVER_ROOT / sub
        if not p.is_file():
            continue
        text = p.read_text(encoding="utf-8", errors="replace")
        for key in ("SQL_HOST", "SQL_LOGIN", "SQL_PASSWORD", "SQL_DATABASE"):
            m = re.search(rf"{key}\s*=\s*'([^']*)'", text)
            if m:
                merged[key] = m.group(1)
        m = re.search(r"SQL_PORT\s*=\s*(\d+)", text)
        if m:
            merged["SQL_PORT"] = m.group(1)
    return merged


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--single-map",
        action="store_true",
        help="Set zoneport = 54230 for all rows with zoneport > 0 (one xi_map process).",
    )
    args = ap.parse_args()

    net = parse_lua_network()
    for req in ("SQL_HOST", "SQL_PORT", "SQL_LOGIN", "SQL_PASSWORD", "SQL_DATABASE"):
        if req not in net:
            print(f"Missing {req} in settings network.lua", file=sys.stderr)
            return 2

    pub = urllib.request.urlopen("https://api.ipify.org", timeout=15).read().decode().strip()
    if not pub or not re.match(r"^\d{1,3}(\.\d{1,3}){3}$", pub):
        print(f"Bad public IP from ipify: {pub!r}", file=sys.stderr)
        return 2

    mysql_dir = os.environ.get("MYSQL_BIN", "").rstrip("/\\")
    if not mysql_dir:
        which = shutil.which("mysql")
        mysql_dir = str(Path(which).parent) if which else ""
    if not mysql_dir or not Path(mysql_dir).is_dir():
        print("Set MYSQL_BIN to directory containing mysql.exe or add mysql to PATH", file=sys.stderr)
        return 2
    mysql = str(Path(mysql_dir) / "mysql.exe") if os.name == "nt" else str(Path(mysql_dir) / "mysql")

    q = pub.replace("'", "''")
    statements = [
        "SELECT DISTINCT zoneip, zoneport FROM zone_settings ORDER BY zoneport;",
        f"UPDATE zone_settings SET zoneip = '{q}' WHERE zoneport > 0;",
    ]
    if args.single_map:
        statements.append("UPDATE zone_settings SET zoneport = 54230 WHERE zoneport > 0;")
    statements.append("SELECT DISTINCT zoneip, zoneport FROM zone_settings ORDER BY zoneport;")

    base = [
        mysql,
        f"--host={net['SQL_HOST']}",
        f"--port={net['SQL_PORT']}",
        f"--user={net['SQL_LOGIN']}",
        f"--password={net['SQL_PASSWORD']}",
        net["SQL_DATABASE"],
        "-e",
    ]

    print(f"Public IPv4: {pub}")
    labels = ["before", "zoneip", "collapse_ports" if args.single_map else None, "after"]
    labels = [x for x in labels if x is not None]
    if len(labels) != len(statements):
        labels = [f"step{i}" for i in range(len(statements))]
    for label, stmt in zip(labels, statements):
        r = subprocess.run([*base, stmt], capture_output=True, text=True)
        print(f"--- {label} ---")
        sys.stdout.write(r.stdout)
        sys.stderr.write(r.stderr)
        if r.returncode != 0:
            return r.returncode

    print("Done. Restart xi_connect (and xi_map if needed).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
