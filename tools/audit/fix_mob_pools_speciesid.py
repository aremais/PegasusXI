"""Restore mob_pools.speciesid from upstream LandSandBoat base SQL.

Only the speciesid column is changed; all other pool fields are preserved
(including intentional PegasusXI combat/skill tweaks on ~171 pools).

Usage (from server repo root):
    py -3 -m tools.audit.fix_mob_pools_speciesid
    py -3 -m tools.audit.fix_mob_pools_speciesid --dry-run
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

from .schemas import MOB_POOLS_COLUMNS
from .sql_parser import HexLiteral, SqlVariable, _parse_tuple, rows_by_key
from .upstream import upstream_path

SPECIESID_INDEX = MOB_POOLS_COLUMNS.index("speciesid")
TABLE = "mob_pools"
DEFAULT_LOCAL = Path("sql/mob_pools.sql")


def _format_sql_value(value: object) -> str:
    if isinstance(value, HexLiteral):
        return str(value)
    if isinstance(value, SqlVariable):
        return str(value)
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace("'", "\\'")
        return f"'{escaped}'"
    if isinstance(value, float):
        return format(value, "g")
    return str(int(value))


def _format_insert(row: list[object]) -> str:
    body = ",".join(_format_sql_value(v) for v in row)
    return f"INSERT INTO `{TABLE}` VALUES ({body});"


def _insert_pattern() -> re.Pattern[str]:
    return re.compile(
        r"INSERT\s+INTO\s+`" + re.escape(TABLE) + r"`\s+VALUES\s*\((.*?)\)\s*;",
        re.IGNORECASE | re.DOTALL,
    )


def fix_file(
    local_path: Path,
    upstream_species: dict[int, int],
    *,
    dry_run: bool = False,
) -> tuple[int, int, int]:
    """Patch speciesid in ``local_path``. Returns (changed, unchanged, skipped)."""
    text = local_path.read_text(encoding="utf-8", errors="replace")
    changed = unchanged = skipped = 0
    parts: list[str] = []
    last_end = 0

    for match in _insert_pattern().finditer(text):
        parts.append(text[last_end : match.start()])
        row = _parse_tuple(match.group(1))
        if len(row) != len(MOB_POOLS_COLUMNS):
            parts.append(match.group(0))
            skipped += 1
            last_end = match.end()
            continue

        poolid = int(row[0])
        upstream_sid = upstream_species.get(poolid)
        if upstream_sid is None:
            parts.append(match.group(0))
            skipped += 1
            last_end = match.end()
            continue

        current_sid = int(row[SPECIESID_INDEX])
        if current_sid == upstream_sid:
            parts.append(match.group(0))
            unchanged += 1
        else:
            row[SPECIESID_INDEX] = upstream_sid
            parts.append(_format_insert(row))
            changed += 1
        last_end = match.end()

    parts.append(text[last_end:])
    new_text = "".join(parts)

    if dry_run:
        return changed, unchanged, skipped

    if changed == 0:
        return changed, unchanged, skipped

    backup = local_path.with_suffix(local_path.suffix + ".bak")
    shutil.copy2(local_path, backup)
    local_path.write_text(new_text, encoding="utf-8", newline="\n")
    print(f"Backup written to {backup}", file=sys.stderr)
    return changed, unchanged, skipped


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--local-sql",
        type=Path,
        default=DEFAULT_LOCAL,
        help=f"Path to mob_pools.sql (default: {DEFAULT_LOCAL})",
    )
    parser.add_argument("--dry-run", action="store_true", help="Report counts only; do not write")
    parser.add_argument("--no-fetch", action="store_true", help="Require cached upstream SQL")
    args = parser.parse_args(argv)

    local_path = args.local_sql.resolve()
    if not local_path.is_file():
        print(f"error: {local_path} not found", file=sys.stderr)
        return 1

    up_path = upstream_path(
        "mob_pools.sql",
        allow_fetch=not args.no_fetch,
    )
    upstream = rows_by_key(up_path, TABLE, MOB_POOLS_COLUMNS, key="poolid")
    upstream_species = {int(pid): int(row["speciesid"]) for pid, row in upstream.items()}

    changed, unchanged, skipped = fix_file(
        local_path,
        upstream_species,
        dry_run=args.dry_run,
    )

    mode = "dry-run" if args.dry_run else "applied"
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    print(f"[{ts}] fix_mob_pools_speciesid ({mode})")
    print(f"  upstream pools:     {len(upstream_species)}")
    print(f"  speciesid fixed:    {changed}")
    print(f"  already correct:    {unchanged}")
    print(f"  skipped (no match): {skipped}")
    if not args.dry_run and changed:
        print(f"  updated:            {local_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
