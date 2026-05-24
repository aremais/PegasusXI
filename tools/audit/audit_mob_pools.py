"""Audit mob pool / species / detection divergence between PegasusXI and upstream LSB.

Output: a CSV plus a Markdown summary listing every pool whose behavior-relevant
fields differ from upstream, with the effective detection bitmask (species
``detects`` overridden by ``MOBMOD_DETECTION`` in ``mob_pool_mods`` when present).

This tool reads SQL files only - no MySQL connection needed - and is therefore
safe to run in CI. It does **not** prove retail correctness; it only highlights
where PegasusXI diverges from LSB ``base``. Pair with BG Wiki / FFXIclopedia /
FFXIDB references for retail validation - see ``README.md`` for next steps.
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .diff_utils import changed_fields, write_csv, write_markdown
from .schemas import (
    MOBMOD_DETECTION,
    MOB_POOLS_COLUMNS,
    MOB_POOL_MODS_COLUMNS,
    MOB_SPECIES_SYSTEM_COLUMNS,
    decode_detects,
)
from .sql_parser import rows_by_key

POOL_BEHAVIOR_FIELDS = [
    "speciesid", "behavior", "aggro", "true_detection", "links",
    "mobType", "immunity", "flag", "entityFlags", "roamflag",
    "spellList", "skill_list_id", "resist_id",
]


@dataclass
class PoolState:
    pools: dict[int, dict[str, Any]]
    species: dict[int, dict[str, Any]]
    detect_overrides: dict[int, int] = field(default_factory=dict)  # poolid -> detect bitmask

    @classmethod
    def load(cls, sql_dir: Path) -> "PoolState":
        pools = rows_by_key(
            sql_dir / "mob_pools.sql", "mob_pools", MOB_POOLS_COLUMNS, key="poolid"
        )
        species = rows_by_key(
            sql_dir / "mob_species_system.sql", "mob_species_system",
            MOB_SPECIES_SYSTEM_COLUMNS, key="speciesID",
        )
        overrides: dict[int, int] = {}
        pool_mods_path = sql_dir / "mob_pool_mods.sql"
        if pool_mods_path.exists():
            for row in _iter_pool_mods(pool_mods_path):
                if row["is_mob_mod"] and row["modid"] == MOBMOD_DETECTION:
                    overrides[row["poolid"]] = row["value"]
        return cls(pools=pools, species=species, detect_overrides=overrides)

    def effective_detects(self, poolid: int) -> tuple[int | None, str]:
        if poolid in self.detect_overrides:
            v = self.detect_overrides[poolid]
            return v, f"override (MOBMOD_DETECTION={v})"
        pool = self.pools.get(poolid)
        if pool is None:
            return None, "no pool"
        sp = self.species.get(pool["speciesid"])
        if sp is None:
            return None, f"missing speciesid={pool['speciesid']}"
        return sp["detects"], f"species {pool['speciesid']}"


def _iter_pool_mods(path: Path):
    from .sql_parser import parse_inserts
    for row in parse_inserts(path, "mob_pool_mods"):
        if len(row) != len(MOB_POOL_MODS_COLUMNS):
            continue
        yield dict(zip(MOB_POOL_MODS_COLUMNS, row))


def compare(local: PoolState, upstream: PoolState) -> list[dict[str, Any]]:
    """Return diff rows for every pool whose behavior fields or effective detects differ."""
    diffs: list[dict[str, Any]] = []
    all_pool_ids = set(local.pools) | set(upstream.pools)
    for pid in sorted(all_pool_ids):
        lp = local.pools.get(pid)
        up = upstream.pools.get(pid)
        if lp is None:
            diffs.append({
                "poolid": pid,
                "status": "only_upstream",
                "name_local": "",
                "name_upstream": up["name"],
                "changes": "(missing locally)",
                "local_detects": "",
                "upstream_detects": _detects_str(upstream, pid),
                **{f"local_{f}": "" for f in POOL_BEHAVIOR_FIELDS},
                **{f"upstream_{f}": up.get(f, "") for f in POOL_BEHAVIOR_FIELDS},
            })
            continue
        if up is None:
            diffs.append({
                "poolid": pid,
                "status": "only_local",
                "name_local": lp["name"],
                "name_upstream": "",
                "changes": "(local-only pool)",
                "local_detects": _detects_str(local, pid),
                "upstream_detects": "",
                **{f"local_{f}": lp.get(f, "") for f in POOL_BEHAVIOR_FIELDS},
                **{f"upstream_{f}": "" for f in POOL_BEHAVIOR_FIELDS},
            })
            continue
        changes = changed_fields(lp, up, POOL_BEHAVIOR_FIELDS)
        local_det, local_src = local.effective_detects(pid)
        up_det, up_src = upstream.effective_detects(pid)
        detect_changed = local_det != up_det
        if not changes and not detect_changed:
            continue
        if detect_changed and "detects" not in changes:
            changes.append("effective_detects")
        diffs.append({
            "poolid": pid,
            "status": "changed",
            "name_local": lp["name"],
            "name_upstream": up["name"],
            "changes": ",".join(changes),
            "local_detects": f"{decode_detects(local_det)} [{local_src}]" if local_det is not None else f"[{local_src}]",
            "upstream_detects": f"{decode_detects(up_det)} [{up_src}]" if up_det is not None else f"[{up_src}]",
            **{f"local_{f}": lp.get(f, "") for f in POOL_BEHAVIOR_FIELDS},
            **{f"upstream_{f}": up.get(f, "") for f in POOL_BEHAVIOR_FIELDS},
        })
    return diffs


def _detects_str(state: PoolState, pid: int) -> str:
    v, src = state.effective_detects(pid)
    return f"{decode_detects(v)} [{src}]" if v is not None else f"[{src}]"


def run(local_sql_dir: Path, upstream_sql_dir: Path, output_dir: Path, *, limit: int | None = None) -> dict[str, Path]:
    local = PoolState.load(local_sql_dir)
    upstream = PoolState.load(upstream_sql_dir)
    diffs = compare(local, upstream)
    if limit is not None:
        diffs = diffs[:limit]
    output_dir.mkdir(parents=True, exist_ok=True)
    csv_header = [
        "poolid", "status", "name_local", "name_upstream", "changes",
        "local_detects", "upstream_detects",
        *[f"local_{f}" for f in POOL_BEHAVIOR_FIELDS],
        *[f"upstream_{f}" for f in POOL_BEHAVIOR_FIELDS],
    ]
    csv_rows = [[d[h] for h in csv_header] for d in diffs]
    csv_path = output_dir / "mob_pools_divergence.csv"
    write_csv(csv_path, csv_header, csv_rows)

    md_path = output_dir / "mob_pools_divergence.md"
    summary_header = ["poolid", "name", "status", "changes", "local_detects", "upstream_detects"]
    summary_rows = [
        [d["poolid"], d["name_local"] or d["name_upstream"], d["status"],
         d["changes"], d["local_detects"], d["upstream_detects"]]
        for d in diffs
    ]
    counts_header = ["status", "count"]
    by_status: dict[str, int] = {}
    for d in diffs:
        by_status[d["status"]] = by_status.get(d["status"], 0) + 1
    counts_rows = [[k, v] for k, v in sorted(by_status.items())]
    write_markdown(
        md_path,
        "Mob pool / species / detection divergence (PegasusXI vs LandSandBoat base)",
        [
            ("Summary by status", counts_header, counts_rows),
            (f"Divergent pools (top {len(summary_rows)})", summary_header, summary_rows),
        ],
    )
    return {"csv": csv_path, "md": md_path, "count": len(diffs)}  # type: ignore[dict-item]


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--local-sql", type=Path, default=Path("sql"))
    p.add_argument("--upstream-sql", type=Path, default=None,
                   help="Directory of upstream SQL files; if unset, fetch/cache from LSB base.")
    p.add_argument("--output", type=Path, default=Path("tools/audit/reports"))
    p.add_argument("--no-fetch", action="store_true", help="Require cached upstream files; fail if missing.")
    p.add_argument("--limit", type=int, default=None)
    args = p.parse_args(argv)

    if args.upstream_sql is None:
        from . import upstream
        files = upstream.ensure_all(allow_fetch=not args.no_fetch)
        upstream_dir = next(iter(files.values())).parent
    else:
        upstream_dir = args.upstream_sql

    res = run(args.local_sql, upstream_dir, args.output, limit=args.limit)
    print(f"Wrote {res['csv']} and {res['md']} ({res['count']} divergent rows)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
