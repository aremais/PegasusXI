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


REF_FIELDS = [
    "bgwiki_detects", "bgwiki_confidence", "bgwiki_url",
    "ffxiclopedia_detects", "ffxiclopedia_confidence", "ffxiclopedia_url",
    "ref_agreement", "ref_headline_confidence",
]


def _attach_refs(
    diffs: list[dict[str, Any]],
    *,
    bgwiki_client,
    ffxiclopedia_client,
    names_filter: set[str] | None,
) -> None:
    """In-place enrich pool diffs with BG Wiki / FFXIclopedia detection columns.

    If ``names_filter`` is provided, only mobs whose ``name_local`` or
    ``name_upstream`` are in the filter are looked up; others receive empty
    columns (so the CSV header stays stable).
    """
    from .refs.aggregate import lookup_detection
    for d in diffs:
        for f in REF_FIELDS:
            d.setdefault(f, "")
        mob = d.get("name_local") or d.get("name_upstream")
        if not mob:
            continue
        if names_filter is not None and mob not in names_filter:
            continue
        # Wiki pages use spaces, not underscores.
        wiki_title = mob.replace("_", " ")
        ref = lookup_detection(
            wiki_title,
            bgwiki=bgwiki_client,
            ffxiclopedia=ffxiclopedia_client,
        )
        d["bgwiki_detects"] = ref.bgwiki_decoded
        d["bgwiki_confidence"] = ref.bgwiki_confidence
        d["bgwiki_url"] = ref.bgwiki_url
        d["ffxiclopedia_detects"] = ref.ffxiclopedia_decoded
        d["ffxiclopedia_confidence"] = ref.ffxiclopedia_confidence
        d["ffxiclopedia_url"] = ref.ffxiclopedia_url
        d["ref_agreement"] = ref.agreement
        d["ref_headline_confidence"] = ref.headline_confidence()


def run(
    local_sql_dir: Path,
    upstream_sql_dir: Path,
    output_dir: Path,
    *,
    limit: int | None = None,
    with_refs: bool = False,
    bgwiki_client=None,
    ffxiclopedia_client=None,
    names_filter: set[str] | None = None,
) -> dict[str, Path]:
    local = PoolState.load(local_sql_dir)
    upstream = PoolState.load(upstream_sql_dir)
    diffs = compare(local, upstream)
    if limit is not None:
        diffs = diffs[:limit]
    if with_refs:
        _attach_refs(
            diffs,
            bgwiki_client=bgwiki_client,
            ffxiclopedia_client=ffxiclopedia_client,
            names_filter=names_filter,
        )
    output_dir.mkdir(parents=True, exist_ok=True)
    csv_header = [
        "poolid", "status", "name_local", "name_upstream", "changes",
        "local_detects", "upstream_detects",
        *[f"local_{f}" for f in POOL_BEHAVIOR_FIELDS],
        *[f"upstream_{f}" for f in POOL_BEHAVIOR_FIELDS],
    ]
    if with_refs:
        csv_header += REF_FIELDS
    csv_rows = [[d.get(h, "") for h in csv_header] for d in diffs]
    csv_path = output_dir / "mob_pools_divergence.csv"
    write_csv(csv_path, csv_header, csv_rows)

    md_path = output_dir / "mob_pools_divergence.md"
    summary_header = ["poolid", "name", "status", "changes", "local_detects", "upstream_detects"]
    if with_refs:
        summary_header += ["bgwiki_detects", "ffxiclopedia_detects", "ref_agreement"]
    summary_rows = [
        [d["poolid"], d["name_local"] or d["name_upstream"], d["status"],
         d["changes"], d["local_detects"], d["upstream_detects"],
         *([d.get("bgwiki_detects", ""), d.get("ffxiclopedia_detects", ""), d.get("ref_agreement", "")] if with_refs else [])]
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
    p.add_argument("--with-refs", action="store_true",
                   help="Enrich rows with BG Wiki / FFXIclopedia detection lookups.")
    p.add_argument("--names-file", type=Path, default=None,
                   help="Restrict reference lookups to mob names listed in this file (one per line).")
    args = p.parse_args(argv)

    if args.upstream_sql is None:
        from . import upstream
        files = upstream.ensure_all(allow_fetch=not args.no_fetch)
        upstream_dir = next(iter(files.values())).parent
    else:
        upstream_dir = args.upstream_sql

    bgwiki_client = None
    ffxiclopedia_client = None
    names_filter: set[str] | None = None
    if args.with_refs:
        from .refs.bgwiki import BGWikiClient
        from .refs.ffxiclopedia import FFXIclopediaClient
        bgwiki_client = BGWikiClient(allow_fetch=not args.no_fetch)
        ffxiclopedia_client = FFXIclopediaClient(allow_fetch=not args.no_fetch)
        if args.names_file is not None:
            from .refs.aggregate import names_from_file
            names_filter = set(names_from_file(str(args.names_file)))

    res = run(
        args.local_sql, upstream_dir, args.output,
        limit=args.limit,
        with_refs=args.with_refs,
        bgwiki_client=bgwiki_client,
        ffxiclopedia_client=ffxiclopedia_client,
        names_filter=names_filter,
    )
    print(f"Wrote {res['csv']} and {res['md']} ({res['count']} divergent rows)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
