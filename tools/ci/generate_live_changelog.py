#!/usr/bin/env python3
"""Generate a markdown changelog for a Live promotion between two git revisions."""

import subprocess
import sys
from collections import defaultdict
from datetime import date, datetime, timezone


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True).strip()


def categorize(path: str) -> str:
    if path.startswith("scripts/"):
        return "Scripts (Lua)"
    if path.startswith("sql/"):
        return "SQL"
    if path.startswith("src/"):
        return "C++ source"
    if path.startswith("settings/"):
        return "Settings"
    if path.startswith(".github/"):
        return "GitHub / CI"
    if path.startswith("tools/"):
        return "Tools"
    if path.startswith("modules/"):
        return "Modules"
    return "Other"


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "Usage: generate_live_changelog.py <old_sha> <new_sha> <output_path>",
            file=sys.stderr,
        )
        return 1

    old_sha, new_sha, output_path = sys.argv[1], sys.argv[2], sys.argv[3]

    if old_sha == new_sha:
        with open(output_path, "w", encoding="utf-8") as handle:
            handle.write("No changes were included in this Live promotion.\n")
        return 0

    today = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    commit_count = git("rev-list", "--count", f"{old_sha}..{new_sha}")

    lines = [
        f"## PegasusXI Live Update ({today})",
        "",
        f"- **Previous Live commit:** `{old_sha[:12]}`",
        f"- **New Live commit:** `{new_sha[:12]}`",
        f"- **Commits included:** {commit_count}",
        "",
    ]

    merge_log = git(
        "log",
        f"{old_sha}..{new_sha}",
        "--pretty=format:- %s (`%h`)",
        "--merges",
    )
    commit_log = git(
        "log",
        f"{old_sha}..{new_sha}",
        "--pretty=format:- %s (`%h`) by %an",
        "--no-merges",
    )

    lines.append("### Changes")
    if commit_log:
        lines.append(commit_log)
    elif merge_log:
        lines.append("_Only merge commits were included._")
    else:
        lines.append("_No commits found in range._")

    if merge_log:
        lines.append("")
        lines.append("### Merge commits")
        lines.append(merge_log)

    changed_files = [
        line for line in git("diff", f"{old_sha}..{new_sha}", "--name-only").splitlines() if line
    ]

    lines.append("")
    lines.append(f"### Files updated ({len(changed_files)})")

    grouped: dict[str, list[str]] = defaultdict(list)
    for path in changed_files:
        grouped[categorize(path)].append(path)

    for category in sorted(grouped):
        lines.append("")
        lines.append(f"**{category}**")
        for path in grouped[category][:25]:
            lines.append(f"- `{path}`")
        remaining = len(grouped[category]) - 25
        if remaining > 0:
            lines.append(f"- _...and {remaining} more_")

    stat = git("diff", f"{old_sha}..{new_sha}", "--stat")
    lines.extend(["", "### Diff summary", "", "```", stat, "```", ""])

    with open(output_path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(lines))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
