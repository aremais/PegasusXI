"""Audit mob_droplist divergence between PegasusXI and upstream LSB.

For each (dropId, groupId, itemId) tuple, compare ``groupRate``, ``itemRate``,
and ``dropType`` between local and upstream. Resolve dropId -> mob name(s)
via ``mob_groups.dropid`` -> ``mob_pools.name``, and itemId -> item name via
``item_basic``.

Like ``audit_mob_pools``, this is purely SQL-text-based: no MySQL connection.
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

from .diff_utils import write_csv, write_markdown
from .schemas import (
    ITEM_BASIC_COLUMNS, MOB_DROPLIST_COLUMNS,
    MOB_GROUPS_COLUMNS, MOB_POOLS_COLUMNS,
)
from .sql_parser import parse_inserts, rows_by_key

DROP_COMPARED_FIELDS = ["dropType", "groupRate", "itemRate"]


def _load_dropid_to_pool_names(sql_dir: Path) -> dict[int, list[str]]:
    """Build dropId -> [pool_name, ...] from mob_groups -> mob_pools.

    A single ``dropid`` can be shared across multiple pools (zone variants);
    we keep up to a few names to keep the output digestible.
    """
    pools = rows_by_key(
        sql_dir / "mob_pools.sql", "mob_pools", MOB_POOLS_COLUMNS, key="poolid"
    )
    out: defaultdict[int, list[str]] = defaultdict(list)
    groups_path = sql_dir / "mob_groups.sql"
    if not groups_path.exists():
        return {}
    for row in parse_inserts(groups_path, "mob_groups"):
        if len(row) != len(MOB_GROUPS_COLUMNS):
            continue
        d = dict(zip(MOB_GROUPS_COLUMNS, row))
        dropid = d["dropid"]
        if not dropid:
            continue
        pool = pools.get(d["poolid"])
        if pool is None:
            continue
        name = pool["name"]
        bucket = out[dropid]
        if name not in bucket and len(bucket) < 4:
            bucket.append(name)
    return dict(out)


def _load_item_names(sql_dir: Path) -> dict[int, str]:
    items_path = sql_dir / "item_basic.sql"
    if not items_path.exists():
        return {}
    out: dict[int, str] = {}
    for row in parse_inserts(items_path, "item_basic"):
        if len(row) != len(ITEM_BASIC_COLUMNS):
            continue
        d = dict(zip(ITEM_BASIC_COLUMNS, row))
        out[d["itemid"]] = d["name"]
    return out


def _load_droplist(path: Path) -> dict[tuple[int, int, int], dict[str, Any]]:
    out: dict[tuple[int, int, int], dict[str, Any]] = {}
    for row in parse_inserts(path, "mob_droplist"):
        if len(row) != len(MOB_DROPLIST_COLUMNS):
            continue
        d = dict(zip(MOB_DROPLIST_COLUMNS, row))
        key = (d["dropId"], d["groupId"], d["itemId"])
        # If duplicate, keep the first (matches MariaDB insertion order).
        out.setdefault(key, d)
    return out


def compare(local_dl: dict, upstream_dl: dict) -> list[dict[str, Any]]:
    diffs: list[dict[str, Any]] = []
    all_keys = set(local_dl) | set(upstream_dl)
    for key in sorted(all_keys):
        l = local_dl.get(key)
        u = upstream_dl.get(key)
        if l is None:
            diffs.append({"key": key, "status": "only_upstream", "local": {}, "upstream": u, "changes": ["(missing locally)"]})
            continue
        if u is None:
            diffs.append({"key": key, "status": "only_local", "local": l, "upstream": {}, "changes": ["(local-only)"]})
            continue
        changes = [f for f in DROP_COMPARED_FIELDS if l.get(f) != u.get(f)]
        if not changes:
            continue
        diffs.append({"key": key, "status": "changed", "local": l, "upstream": u, "changes": changes})
    return diffs


def run(local_sql_dir: Path, upstream_sql_dir: Path, output_dir: Path, *, limit: int | None = None) -> dict[str, Any]:
    local_dl = _load_droplist(local_sql_dir / "mob_droplist.sql")
    upstream_dl = _load_droplist(upstream_sql_dir / "mob_droplist.sql")
    diffs = compare(local_dl, upstream_dl)

    pool_names = _load_dropid_to_pool_names(local_sql_dir)
    if not pool_names:
        pool_names = _load_dropid_to_pool_names(upstream_sql_dir)
    item_names = _load_item_names(local_sql_dir)
    if not item_names:
        item_names = _load_item_names(upstream_sql_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    csv_header = [
        "dropId", "groupId", "itemId", "item_name", "mob_names", "status", "changes",
        "local_dropType", "upstream_dropType",
        "local_groupRate", "upstream_groupRate",
        "local_itemRate", "upstream_itemRate",
    ]
    csv_rows: list[list[Any]] = []
    for d in diffs:
        dropid, gid, iid = d["key"]
        l, u = d["local"], d["upstream"]
        csv_rows.append([
            dropid, gid, iid,
            item_names.get(iid, ""),
            ";".join(pool_names.get(dropid, [])),
            d["status"], ",".join(d["changes"]),
            l.get("dropType", ""), u.get("dropType", ""),
            l.get("groupRate", ""), u.get("groupRate", ""),
            l.get("itemRate", ""), u.get("itemRate", ""),
        ])
    if limit is not None:
        csv_rows = csv_rows[:limit]

    csv_path = output_dir / "mob_droplist_divergence.csv"
    write_csv(csv_path, csv_header, csv_rows)

    md_summary_header = [
        "dropId", "groupId", "itemId", "item", "mob(s)", "status", "changes",
        "local_groupRate/itemRate", "upstream_groupRate/itemRate",
    ]
    md_rows: list[list[Any]] = []
    for r in csv_rows[:500]:  # cap Markdown preview
        (
            dropid, gid, iid, iname, mnames, status, changes,
            l_dt, u_dt, l_gr, u_gr, l_ir, u_ir,
        ) = r
        md_rows.append([
            dropid, gid, iid, iname, mnames, status, changes,
            f"{l_gr}/{l_ir}", f"{u_gr}/{u_ir}",
        ])

    by_status: dict[str, int] = {}
    for d in diffs:
        by_status[d["status"]] = by_status.get(d["status"], 0) + 1

    md_path = output_dir / "mob_droplist_divergence.md"
    write_markdown(
        md_path,
        "mob_droplist divergence (PegasusXI vs LandSandBoat base)",
        [
            ("Summary by status", ["status", "count"], [[k, v] for k, v in sorted(by_status.items())]),
            (f"Divergent drop slots (showing {len(md_rows)} of {len(csv_rows)})", md_summary_header, md_rows),
        ],
    )
    return {"csv": csv_path, "md": md_path, "count": len(csv_rows), "total_diffs": len(diffs)}


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--local-sql", type=Path, default=Path("sql"))
    p.add_argument("--upstream-sql", type=Path, default=None)
    p.add_argument("--output", type=Path, default=Path("tools/audit/reports"))
    p.add_argument("--no-fetch", action="store_true")
    p.add_argument("--limit", type=int, default=None)
    args = p.parse_args(argv)

    if args.upstream_sql is None:
        from . import upstream
        files = upstream.ensure_all(allow_fetch=not args.no_fetch)
        upstream_dir = next(iter(files.values())).parent
    else:
        upstream_dir = args.upstream_sql

    res = run(args.local_sql, upstream_dir, args.output, limit=args.limit)
    print(f"Wrote {res['csv']} and {res['md']} ({res['count']} rows of {res['total_diffs']} divergent slots)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
