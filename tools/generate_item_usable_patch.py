#!/usr/bin/env python3
"""Generate SQL patch for item_usable rows present upstream but missing locally."""
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_URL = "https://raw.githubusercontent.com/LandSandBoat/server/base/sql/item_usable.sql"

TYPE_VARS = {
    "@GENERAL_TYPE": 1,
    "@LINKSHELL_TYPE": 2,
    "@FURNISHING_TYPE": 3,
    "@PUPPET_TYPE": 4,
    "@USABLE_TYPE": 5,
    "@EQUIPMENT_TYPE": 6,
    "@WEAPON_TYPE": 7,
    "@CURRENCY_TYPE": 8,
}


def parse_usable_inserts(text: str) -> dict[int, str]:
    rows: dict[int, str] = {}
    for line in text.splitlines():
        if not line.startswith("INSERT INTO `item_usable`"):
            continue
        itemid = int(re.match(r"INSERT INTO `item_usable` VALUES \((\d+),", line).group(1))
        rows[itemid] = line
    return rows


def resolve_type(token: str) -> int | None:
    token = token.strip()
    if token in TYPE_VARS:
        return TYPE_VARS[token]
    try:
        return int(token)
    except ValueError:
        return None


def parse_fields(line: str) -> list[str]:
    parts = line.split("VALUES (", 1)[1].rstrip(");\n")
    fields: list[str] = []
    cur = ""
    in_quote = False
    for ch in parts:
        if ch == "'":
            in_quote = not in_quote
            cur += ch
        elif ch == "," and not in_quote:
            fields.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur:
        fields.append(cur.strip())
    return fields


def usable_basic_ids() -> set[int]:
    ids: set[int] = set()
    with open(ROOT / "sql/item_basic.sql", encoding="utf-8", errors="ignore") as f:
        for line in f:
            if "INSERT INTO `item_basic`" not in line:
                continue
            fields = parse_fields(line)
            if len(fields) < 6:
                continue
            typ = resolve_type(fields[5])
            if typ == 5:
                ids.add(int(fields[0]))
    return ids


def item_name(itemid: int) -> str:
    with open(ROOT / "sql/item_basic.sql", encoding="utf-8", errors="ignore") as f:
        for line in f:
            m = re.match(rf"INSERT INTO `item_basic` VALUES \({itemid},[^,]*,'([^']*)'", line)
            if m:
                return m.group(1)
    return f"item_{itemid}"


def main() -> None:
    local_path = ROOT / "sql/item_usable.sql"
    local_text = local_path.read_text(encoding="utf-8", errors="ignore")
    with urllib.request.urlopen(UPSTREAM_URL, timeout=60) as resp:
        upstream_text = resp.read().decode("utf-8", errors="ignore")

    local_rows = parse_usable_inserts(local_text)
    upstream_rows = parse_usable_inserts(upstream_text)
    usable_ids = usable_basic_ids()
    missing_ids = sorted(i for i in usable_ids if i not in local_rows)

    patch_lines: list[str] = []
    insert_lines: list[str] = []
    upstream_count = 0
    placeholder_count = 0

    for itemid in missing_ids:
        if itemid in upstream_rows:
            upstream_count += 1
            insert_line = upstream_rows[itemid]
            patch_line = insert_line.replace("INSERT INTO", "INSERT IGNORE INTO", 1)
        else:
            placeholder_count += 1
            name = item_name(itemid)
            insert_line = (
                f"INSERT INTO `item_usable` VALUES ({itemid},'{name}',1,1,0,0,0,0,0,0); -- TODO: no upstream row"
            )
            patch_line = insert_line.replace("INSERT INTO", "INSERT IGNORE INTO", 1)

        insert_lines.append(insert_line)
        patch_lines.append(patch_line)

    patch_path = ROOT / "sql/patches/item_usable_missing_rows.sql"
    patch_path.write_text(
        "-- Backfill item_usable rows for item_basic entries typed as Usable (5) but missing extension data.\n"
        "-- Sourced from LandSandBoat/server base where available. Safe to re-run.\n\n"
        + "\n".join(patch_lines)
        + "\n",
        encoding="utf-8",
    )

    # Insert missing rows into item_usable.sql after the last existing row with a lower itemid
    lines = local_text.splitlines(keepends=True)
    out: list[str] = []
    inserted = False
    for line in lines:
        out.append(line)
        m = re.match(r"INSERT INTO `item_usable` VALUES \((\d+),", line)
        if not m or inserted:
            continue
        itemid = int(m.group(1))
        # After the last insert before the first missing block (6612 -> gap at 6613)
        next_missing = missing_ids[0] if missing_ids else None
        if next_missing and itemid < next_missing:
            # peek if next line is higher id or end of block
            idx = lines.index(line)
            next_line = lines[idx + 1] if idx + 1 < len(lines) else ""
            nm = re.match(r"INSERT INTO `item_usable` VALUES \((\d+),", next_line)
            next_id = int(nm.group(1)) if nm else None
            if next_id is None or next_id > next_missing:
                for insert_line in insert_lines:
                    out.append(insert_line + "\n")
                inserted = True

    if not inserted and missing_ids:
        # fallback: append before footer
        for i, line in enumerate(out):
            if line.startswith("/*!40103 SET TIME_ZONE"):
                for insert_line in reversed(insert_lines):
                    out.insert(i, insert_line + "\n")
                inserted = True
                break

    local_path.write_text("".join(out), encoding="utf-8")

    print(f"Missing usable rows: {len(missing_ids)}")
    print(f"From upstream: {upstream_count}")
    print(f"Placeholder only: {placeholder_count}")
    print(f"Patch: {patch_path}")
    print(f"Updated: {local_path}")


if __name__ == "__main__":
    main()
