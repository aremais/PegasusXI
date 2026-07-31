"""``python -m tools.audit <subcommand>`` entry point."""

from __future__ import annotations

import argparse
import sys


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m tools.audit")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("pools", help="Audit mob_pools / species / detection divergence")
    sub.add_parser("drops", help="Audit mob_droplist divergence")
    sub.add_parser("self-check", help="Run a deterministic self-check (no DB, no network)")
    args, rest = p.parse_known_args(argv)
    if args.cmd == "pools":
        from .audit_mob_pools import main as run
        return run(rest)
    if args.cmd == "drops":
        from .audit_drops import main as run
        return run(rest)
    if args.cmd == "self-check":
        from .self_check import main as run
        return run(rest)
    return 2


if __name__ == "__main__":
    sys.exit(main())
