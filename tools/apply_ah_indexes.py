#!/usr/bin/env python3
"""Apply auction_house_search_perf_indexes.sql using settings/network credentials."""

import os
import re
import sys
from pathlib import Path

try:
    import mariadb
except ImportError:
    print("mariadb module not installed; run: pip install mariadb")
    sys.exit(1)

SERVER_ROOT = Path(__file__).resolve().parents[1]


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


def main() -> int:
    cfg = read_network_settings()
    statements = [
        "CREATE INDEX IF NOT EXISTS `idx_item_basic_ah` ON `item_basic` (`aH`)",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_item_buyer` ON `auction_house` (`itemid`, `buyer_name`)",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_item_stack_sell` ON `auction_house` (`itemid`, `stack`, `sell_date`)",
        "CREATE INDEX IF NOT EXISTS `idx_auction_house_buyer_date` ON `auction_house` (`buyer_name`, `date`)",
    ]

    print(f"Connecting to {cfg['SQL_LOGIN']}@{cfg['SQL_HOST']}:{cfg['SQL_PORT']}/{cfg['SQL_DATABASE']}")
    conn = mariadb.connect(
        host=cfg["SQL_HOST"],
        user=cfg["SQL_LOGIN"],
        passwd=cfg["SQL_PASSWORD"],
        db=cfg["SQL_DATABASE"],
        port=int(cfg["SQL_PORT"]),
    )
    cur = conn.cursor()
    for stmt in statements:
        print(f"Executing: {stmt[:80]}...")
        cur.execute(stmt)
    conn.commit()

    cur.execute("SHOW INDEX FROM item_basic WHERE Key_name = 'idx_item_basic_ah'")
    ah_idx = cur.fetchall()
    print(f"idx_item_basic_ah present: {len(ah_idx) > 0}")
    cur.execute("SHOW INDEX FROM auction_house WHERE Key_name LIKE 'idx_auction_house%'")
    print(f"auction_house perf indexes: {len(cur.fetchall())}")
    cur.close()
    conn.close()
    print("Done.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except mariadb.Error as e:
        print(f"Database error: {e}")
        raise SystemExit(1)
