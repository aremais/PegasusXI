#!/usr/bin/env python3
"""
One-shot database recovery when servers are stopped.

Typical use (from repo root):
  python tools/recover_server_db.py
  python tools/recover_server_db.py --start-servers

Or use the PowerShell wrapper:
  .\\tools\\recover_server.ps1
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
SERVER_ROOT = os.path.dirname(TOOLS_DIR)
os.chdir(SERVER_ROOT)
sys.path.insert(0, TOOLS_DIR)

import dbtool  # noqa: E402

REQUIRED_TRIGGERS = [
    "account_delete",
    "session_delete",
    "auction_house_list",
    "auction_house_buy",
    "char_insert",
    "char_delete",
    "delivery_box_insert",
    "ensure_synth_ingredients_are_ordered",
    "ensure_synergy_ingredients_are_ordered",
]

SERVER_PROCESSES = ("xi_connect", "xi_world", "xi_search", "xi_map")


def _running_server_processes() -> list[str]:
    found: list[str] = []
    if os.name == "nt":
        for name in SERVER_PROCESSES:
            exe = f"{name}.exe"
            result = subprocess.run(
                ["tasklist", "/FI", f"IMAGENAME eq {exe}", "/NH"],
                capture_output=True,
                text=True,
            )
            if exe.lower() in result.stdout.lower():
                found.append(name)
    else:
        for name in SERVER_PROCESSES:
            if subprocess.run(["pgrep", "-x", name], capture_output=True).returncode == 0:
                found.append(name)
    return found


def kill_stuck_queries() -> int:
    dbtool.connect()
    cur = dbtool.cur
    cur.execute("SHOW FULL PROCESSLIST")
    killed = 0
    for row in cur.fetchall():
        pid, _user, _host, _db, _cmd, time_s, state, info = row[:8]
        if pid == cur.connection.thread_id:
            continue
        info = info or ""
        state = state or ""
        if time_s < 60:
            continue
        should_kill = (
            ("CREATE INDEX" in info and "item_basic" in info)
            or "Waiting for table metadata lock" in state
            or ("auction_house" in info and time_s > 300)
        )
        if should_kill:
            print(f"  KILL {pid} ({time_s}s): {info[:70]}...", flush=True)
            try:
                cur.execute(f"KILL {pid}")
                killed += 1
            except Exception as err:
                print(f"    (skip: {err})", flush=True)
    dbtool.db.commit()
    return killed


def missing_triggers() -> list[str]:
    cur = dbtool.cur
    placeholders = ",".join(["%s"] * len(REQUIRED_TRIGGERS))
    cur.execute(
        f"SELECT trigger_name FROM information_schema.triggers "
        f"WHERE trigger_schema = %s AND trigger_name IN ({placeholders})",
        (dbtool.database, *REQUIRED_TRIGGERS),
    )
    found = {row[0] for row in cur.fetchall()}
    return [name for name in REQUIRED_TRIGGERS if name not in found]


def reset_auction_house() -> None:
    cur = dbtool.cur
    cur.execute("SELECT COUNT(*) FROM auction_house")
    before = cur.fetchone()[0]
    print(f"  auction_house rows before: {before:,}", flush=True)
    print("  TRUNCATE auction_house ...", flush=True)
    cur.execute("TRUNCATE TABLE `auction_house`")
    print("  TRUNCATE auction_house_items ...", flush=True)
    cur.execute("TRUNCATE TABLE `auction_house_items`")
    cur.execute(
        "SELECT COUNT(*) FROM information_schema.tables "
        "WHERE table_schema = %s AND table_name = 'auction_house_history'",
        (dbtool.database,),
    )
    if cur.fetchone()[0]:
        print("  TRUNCATE auction_house_history ...", flush=True)
        cur.execute("TRUNCATE TABLE `auction_house_history`")
    dbtool.db.commit()
    cur.execute("SELECT COUNT(*) FROM auction_house")
    after = cur.fetchone()[0]
    print(f"  auction_house rows after: {after:,}", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Recover DB for LandSandBoat startup (triggers + fresh AH)."
    )
    parser.add_argument(
        "--keep-ah",
        action="store_true",
        help="Do not truncate auction_house / auction_house_items.",
    )
    parser.add_argument(
        "--with-indexes",
        action="store_true",
        help="Apply search perf indexes after cleanup (can be slow).",
    )
    parser.add_argument(
        "--start-servers",
        action="store_true",
        help="Launch xi_connect, xi_search, xi_world, and xi_map after DB work.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Continue even if xi_* processes appear to be running.",
    )
    args = parser.parse_args()

    print("LandSandBoat server DB recovery", flush=True)
    print(f"Server root: {SERVER_ROOT}", flush=True)

    running = _running_server_processes()
    if running and not args.force:
        print(
            "ERROR: These processes are still running (stop them first, or use --force):\n  "
            + ", ".join(running),
            flush=True,
        )
        return 1
    if running and args.force:
        print("WARNING: Continuing with --force while running: " + ", ".join(running), flush=True)

    dbtool.fetch_credentials()
    dbtool.fetch_configs()

    print("\n[1/4] Clearing stuck database queries ...", flush=True)
    killed = kill_stuck_queries()
    print(f"  Killed {killed} connection(s).", flush=True)

    print("\n[2/4] Checking required triggers (xi_map startup) ...", flush=True)
    missing = missing_triggers()
    if missing:
        print("  Missing: " + ", ".join(missing), flush=True)
        path = dbtool.from_server_path("sql/fix_all_required_triggers.sql")
        print(f"  Installing from {path} ...", flush=True)
        dbtool.import_file_verbose(path)
        missing = missing_triggers()
        if missing:
            print("ERROR: Still missing triggers: " + ", ".join(missing), flush=True)
            return 1
    print("  All required triggers present.", flush=True)

    if not args.keep_ah:
        print("\n[3/4] Resetting auction house (empty AH) ...", flush=True)
        print(
            "  WARNING: Active listings are deleted, not returned to delivery_box.",
            flush=True,
        )
        reset_auction_house()
    else:
        print("\n[3/4] Skipping auction house reset (--keep-ah).", flush=True)

    if args.with_indexes:
        print("\n[4/4] Applying auction house search indexes ...", flush=True)
        dbtool.execute_ah_search_indexes_with_progress(silent=False)
    else:
        print(
            "\n[4/4] Skipping search indexes (not required for xi_map). "
            "Use --with-indexes later if needed.",
            flush=True,
        )

    print("\nDatabase recovery finished.", flush=True)
    print("Next: start servers (or pass --start-servers).", flush=True)

    if args.start_servers:
        print("\nStarting server processes ...", flush=True)
        time.sleep(1)
        dbtool.launch_using_zone_settings()

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("\nCancelled.", flush=True)
        raise SystemExit(130)
