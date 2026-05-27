#!/usr/bin/env python3
"""Apply auction_house_search_perf_indexes.sql with per-index progress output."""

import os
import re
import sys
import time
from pathlib import Path

try:
    import mariadb
except ImportError:
    print("mariadb module not installed; run: pip install mariadb")
    sys.exit(1)

SERVER_ROOT = Path(__file__).resolve().parents[1]

# Keep in sync with sql/auction_house_search_perf_indexes.sql and dbtool.AH_SEARCH_INDEX_STATEMENTS
INDEX_STATEMENTS = [
    (
        "idx_item_basic_ah",
        "item_basic",
        "CREATE INDEX IF NOT EXISTS `idx_item_basic_ah` ON `item_basic` (`aH`)",
    ),
    (
        "idx_auction_house_item_buyer",
        "auction_house",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_item_buyer` ON `auction_house` (`itemid`, `buyer_name`)",
    ),
    (
        "idx_auction_house_item_stack_sell",
        "auction_house",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_item_stack_sell` ON `auction_house` (`itemid`, `stack`, `sell_date`)",
    ),
    (
        "idx_auction_house_buyer_date",
        "auction_house",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_buyer_date` ON `auction_house` (`buyer_name`, `date`)",
    ),
]


def read_network_settings() -> dict[str, str]:
    path = SERVER_ROOT / "settings" / "network.lua"
    if not path.exists():
        path = SERVER_ROOT / "settings" / "default" / "network.lua"
    text = path.read_text(encoding="utf-8", errors="replace")
    out: dict[str, str] = {}
    for key in ("SQL_HOST", "SQL_PORT", "SQL_LOGIN", "SQL_PASSWORD", "SQL_DATABASE"):
        env = os.getenv(f"XI_NETWORK_{key}")
        if env:
            out[key] = env
            continue
        m = re.search(rf"{key}\s*=\s*['\"]?([^,'\"\n]+)['\"]?", text)
        if m:
            out[key] = m.group(1)
    return out


def index_exists(cur, table: str, index_name: str) -> bool:
    cur.execute(f"SHOW INDEX FROM `{table}` WHERE Key_name = %s", (index_name,))
    return cur.fetchone() is not None


def main() -> int:
    cfg = read_network_settings()
    print(
        f"Connecting to {cfg['SQL_LOGIN']}@{cfg['SQL_HOST']}:{cfg['SQL_PORT']}/{cfg['SQL_DATABASE']}",
        flush=True,
    )
    conn = mariadb.connect(
        host=cfg["SQL_HOST"],
        user=cfg["SQL_LOGIN"],
        passwd=cfg["SQL_PASSWORD"],
        db=cfg["SQL_DATABASE"],
        port=int(cfg["SQL_PORT"]),
    )
    cur = conn.cursor()

    try:
        cur.execute("SELECT COUNT(*) FROM auction_house")
        n = cur.fetchone()[0]
        print(f"auction_house row count: {n:,}", flush=True)
        if n > 500000:
            print(
                "Warning: large table; new indexes can take hours. Stop all servers first.",
                flush=True,
            )
    except mariadb.Error as e:
        print(f"Could not read auction_house size: {e}", flush=True)

    total = len(INDEX_STATEMENTS)
    for step, (index_name, table, stmt) in enumerate(INDEX_STATEMENTS, 1):
        print(f"[{step}/{total}] {index_name} on `{table}` ...", flush=True)
        if index_exists(cur, table, index_name):
            print("  already present, skipping.", flush=True)
            continue
        started = time.perf_counter()
        cur.execute(stmt)
        conn.commit()
        print(f"  done ({time.perf_counter() - started:.1f}s).", flush=True)

    print("Done.", flush=True)
    cur.close()
    conn.close()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except mariadb.Error as e:
        print(f"Database error: {e}", flush=True)
        raise SystemExit(1)
