"""Deterministic dry-run that exercises the audit tooling against tiny SQL fixtures.

Intended for CI: no MySQL, no network. Exit code 0 means the parser and diff
logic produced the expected number of divergences across the bundled fixtures.
"""

from __future__ import annotations

import argparse
import sys
import tempfile
from pathlib import Path

from . import audit_drops, audit_mob_pools

FIXTURES = Path(__file__).parent / "tests" / "fixtures"

EXPECTED_POOL_DIFFS = 4   # poolid 100 fields, 101 effective_detects, 102 local-only, 103 upstream-only
EXPECTED_DROP_DIFFS = 3   # (1,0,1000) itemRate, (2,0,2000) local-only, (1,0,1002) upstream-only


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path, default=None,
                   help="Where to write the reports (default: temp dir)")
    args = p.parse_args(argv)

    with tempfile.TemporaryDirectory() as tmp:
        out = args.output if args.output is not None else Path(tmp)
        out.mkdir(parents=True, exist_ok=True)

        pools_res = audit_mob_pools.run(FIXTURES / "local", FIXTURES / "upstream", out)
        drops_res = audit_drops.run(FIXTURES / "local", FIXTURES / "upstream", out)

        problems: list[str] = []
        if pools_res["count"] != EXPECTED_POOL_DIFFS:
            problems.append(f"pool diffs: expected {EXPECTED_POOL_DIFFS}, got {pools_res['count']}")
        if drops_res["count"] != EXPECTED_DROP_DIFFS:
            problems.append(f"drop diffs: expected {EXPECTED_DROP_DIFFS}, got {drops_res['count']}")

        print(f"pools report: {pools_res['csv']} ({pools_res['count']} divergent)")
        print(f"drops report: {drops_res['csv']} ({drops_res['count']} divergent)")
        if problems:
            for prob in problems:
                print(f"FAIL: {prob}", file=sys.stderr)
            return 1
        print("self-check OK")
        return 0


if __name__ == "__main__":
    sys.exit(main())
