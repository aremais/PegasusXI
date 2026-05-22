#!/usr/bin/env python3
"""
Verify mob_family_system.detects against bg-wiki Category pages (MediaWiki API).

Usage:
  python sync_family_detection_from_wiki.py              # report only
  python sync_family_detection_from_wiki.py --apply    # patch mob_family_system.sql
  python sync_family_detection_from_wiki.py --apply --include-unchanged  # rewrite all from wiki
"""
from __future__ import annotations

import argparse
import json
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FAMILY_SQL = ROOT / "sql" / "mob_family_system.sql"
REPORT_JSON = ROOT / "tools" / "wiki_family_detection.json"
REPORT_TXT = ROOT / "tools" / "wiki_family_detection_report.txt"
WIKI_API = "https://www.bg-wiki.com/api.php"

# Server DETECT bits (mobentity.h)
SIGHT = 0x001
HEARING = 0x002
LOWHP = 0x004
MAGIC = 0x020
WS = 0x040
JA = 0x080
SCENT = 0x100

DETECT_NAMES = {
    0: "NONE",
    1: "SIGHT",
    2: "HEARING",
    3: "SIGHT+HEARING",
    4: "LOWHP",
    6: "LOWHP+HEARING",
    7: "SIGHT+HEARING+LOWHP",
    32: "MAGIC",
    33: "MAGIC+SIGHT",
    34: "MAGIC+SIGHT+NONE2",
    64: "WS",
    128: "JA",
    129: "SIGHT+JA",
    192: "WS+JA",
    193: "SIGHT+WS+JA",
    256: "SCENT",
    257: "SCENT+SIGHT",
    258: "SCENT+HEARING",
    259: "SCENT+SIGHT+HEARING",
}


def decode(d: int) -> str:
    if d in DETECT_NAMES:
        return DETECT_NAMES[d]
    parts = []
    for bit, name in [
        (SIGHT, "SIGHT"),
        (HEARING, "HEARING"),
        (LOWHP, "LOWHP"),
        (MAGIC, "MAGIC"),
        (WS, "WS"),
        (JA, "JA"),
        (SCENT, "SCENT"),
    ]:
        if d & bit:
            parts.append(name)
    return "+".join(parts) if parts else str(d)


def split_sql_values(vals: str) -> list[str]:
    parts = []
    cur = ""
    in_q = False
    for ch in vals:
        if ch == "'" and (not cur or cur[-1] != "\\"):
            in_q = not in_q
            cur += ch
        elif ch == "," and not in_q:
            parts.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur:
        parts.append(cur.strip())
    return parts


def parse_families() -> list[dict]:
    text = FAMILY_SQL.read_text(encoding="utf-8", errors="replace")
    rows = []
    for m in re.finditer(r"INSERT INTO `mob_family_system` VALUES \((.+?)\);", text, re.DOTALL):
        parts = split_sql_values(m.group(1))
        rows.append(
            {
                "familyID": int(parts[0]),
                "family": parts[1].strip("'"),
                "superFamily": parts[3].strip("'"),
                "ecosystem": parts[5].strip("'"),
                "detects": int(parts[21]),
            }
        )
    return rows


def wiki_category_title(super_family: str) -> str:
    return "Category:" + super_family.replace("_", " ")


def fetch_wikitext(page: str) -> str | None:
    params = urllib.parse.urlencode(
        {
            "action": "parse",
            "page": page,
            "prop": "wikitext",
            "format": "json",
        }
    )
    url = f"{WIKI_API}?{params}"
    req = urllib.request.Request(url, headers={"User-Agent": "LandSandBoat-family-audit/2.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.load(resp)
    if "error" in data:
        return None
    return data["parse"]["wikitext"]["*"]


def wiki_detects_to_bits(raw: str) -> int:
    """Parse bg-wiki Detects= field from Monster Notes / category template."""
    s = raw.strip().lower()
    # True Sight/Sound are mob flags (true_detection), not family detects bits
    s = re.sub(r"true\s*sight", "", s)
    s = re.sub(r"true\s*sound", "", s)
    s = re.sub(r"links?", "", s)
    s = s.replace("and", ",")

    bits = 0
    if re.search(r"\bsight\b", s):
        bits |= SIGHT
    if re.search(r"\bsound\b|\bhearing\b", s):
        bits |= HEARING
    if re.search(r"\bhp\b|\bbleed", s):
        bits |= LOWHP
    if re.search(r"\bmagic\b", s):
        bits |= MAGIC
    if re.search(r"\bweapon\s*skill\b|\bws\b", s):
        bits |= WS
    if re.search(r"\bjob\s*abilit|\bja\b|\babilities\b", s):
        bits |= JA
    if re.search(r"\bscent\b|\bsmell\b", s):
        bits |= SCENT
    return bits


def parse_wiki_detects(wikitext: str) -> tuple[int | None, str]:
    if not wikitext:
        return None, "no-page"
    matches = re.findall(r"Detects\s*=\s*([^\n|}\]]+)", wikitext, re.I)
    cleaned = []
    for m in matches:
        m = m.strip()
        if m.startswith("{{") or not m:
            continue
        cleaned.append(m)
    if not cleaned:
        return None, "no-detects-field"
    # Prefer shortest non-empty (category infobox); skip broken templates
    best = min(cleaned, key=len)
    bits = wiki_detects_to_bits(best)
    return bits, f"wiki:{best}"


# Families where lua/scripts override detection — keep DB unless wiki is explicit
SCRIPT_OVERRIDE_SUPER = {
    "Imp",  # imp_aggro.lua: day sound, night sight+sound
}

# Not wild mobs — wiki says "Varies" / N/A
SKIP_SUPER = {
    "Avatar",
    "Altana",
    "Aminon",
    "Automaton",
    "Unclassified",
    "Ultima",
    "Wyvern_(Pet)",
}


def should_apply_wiki(sf: str, bits: int | None, src: str) -> bool:
    if sf in SCRIPT_OVERRIDE_SUPER or sf in SKIP_SUPER:
        return False
    if bits is None or not src.startswith("wiki:"):
        return False
    raw = src[5:].lower()
    if "varies" in raw or raw in ("true sound", "true sight"):
        return False
    return True


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--delay", type=float, default=0.3)
    args = parser.parse_args()

    families = parse_families()
    superfamilies = sorted({f["superFamily"] for f in families})

    wiki_data: dict[str, dict] = {}
    if REPORT_JSON.exists():
        try:
            wiki_data = json.loads(REPORT_JSON.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            wiki_data = {}

    for sf in superfamilies:
        if sf in wiki_data and wiki_data[sf].get("detects") is not None and not str(
            wiki_data[sf].get("source", "")
        ).startswith("http-"):
            continue
        page = wiki_category_title(sf)
        bits = None
        src = "error"
        for attempt in range(4):
            try:
                wt = fetch_wikitext(page)
                if wt is None:
                    src = "missing-page"
                else:
                    bits, src = parse_wiki_detects(wt)
                break
            except urllib.error.HTTPError as e:
                if e.code == 429 and attempt < 3:
                    time.sleep(5 * (attempt + 1))
                    continue
                src = f"http-{e.code}"
                break
            except Exception as e:
                src = f"error:{e}"
                break

        wiki_data[sf] = {
            "detects": bits,
            "source": src,
            "page": f"https://www.bg-wiki.com/ffxi/{urllib.parse.quote(page)}",
        }
        print(f"{sf:24} wiki={decode(bits) if bits is not None else '???':18} ({src})")
        time.sleep(args.delay)

    REPORT_JSON.write_text(json.dumps(wiki_data, indent=2), encoding="utf-8")

    mismatches = []
    skipped = []
    for f in families:
        sf = f["superFamily"]
        w = wiki_data[sf]
        if w["detects"] is None:
            skipped.append(f)
            continue
        if sf in SCRIPT_OVERRIDE_SUPER or sf in SKIP_SUPER:
            skipped.append(f)
            continue
        if w["detects"] is None:
            skipped.append(f)
            continue
        if f["detects"] != w["detects"]:
            row = {**f, "wiki_detects": w["detects"], "wiki_src": w["source"], "wiki_url": w["page"]}
            row["apply"] = should_apply_wiki(sf, w["detects"], w["source"])
            mismatches.append(row)

    lines = [
        "bg-wiki family detection audit (Category: pages via MediaWiki API)",
        f"Families: {len(families)} | Superfamilies: {len(superfamilies)}",
        f"Mismatches (wiki parsed vs mob_family_system): {len(mismatches)}",
        f"Skipped (no wiki field or script override): {len(skipped)}",
        "",
        "=== MISMATCHES ===",
    ]
    for m in sorted(mismatches, key=lambda x: x["superFamily"]):
        lines.append(
            f"  {m['familyID']:3} {m['family']:22} | {m['superFamily']:20} | "
            f"DB {m['detects']:3} ({decode(m['detects']):16}) -> "
            f"wiki {m['wiki_detects']:3} ({decode(m['wiki_detects']):16}) | {m['wiki_src']}"
        )
        lines.append(f"      {m['wiki_url']}")

    lines.extend(["", "=== SCRIPT OVERRIDES (verify in scripts/mixins, not auto-changed) ==="])
    for sf in sorted(SCRIPT_OVERRIDE_SUPER):
        lines.append(f"  {sf}")

    REPORT_TXT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"\nReport: {REPORT_TXT}")
    print(f"JSON:   {REPORT_JSON}")
    print(f"Mismatches: {len(mismatches)}")

    to_apply = [m for m in mismatches if m.get("apply")]
    lines.append(f"\nEligible for --apply (parsed wiki, not skipped): {len(to_apply)}")

    if args.apply and to_apply:
        text = FAMILY_SQL.read_text(encoding="utf-8", errors="replace")
        fixes = {m["familyID"]: m["wiki_detects"] for m in to_apply}

        def repl(m: re.Match) -> str:
            parts = split_sql_values(m.group(1))
            fid = int(parts[0])
            if fid in fixes:
                parts[21] = str(fixes[fid])
            return f"INSERT INTO `mob_family_system` VALUES ({','.join(parts)});"

        new_text = re.sub(
            r"INSERT INTO `mob_family_system` VALUES \((.+?)\);",
            repl,
            text,
            flags=re.DOTALL,
        )
        FAMILY_SQL.write_text(new_text, encoding="utf-8")
        print(f"Applied {len(fixes)} wiki-based detects fixes to mob_family_system.sql")
    elif args.apply:
        print("No eligible wiki fixes to apply.")


if __name__ == "__main__":
    main()
