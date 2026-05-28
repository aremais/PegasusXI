#!/usr/bin/env python3
"""Compare Metalworks zone text IDs and NPC references: Pegasus vs LSB upstream/base."""

import csv
import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ZONE_DIR = REPO / "scripts" / "zones" / "Metalworks"
IDS_PATH = "scripts/zones/Metalworks/IDs.lua"
LSB_REF = "upstream/base"


def git_show(path: str) -> str:
    result = subprocess.run(
        ["git", "show", f"{LSB_REF}:{path}"],
        capture_output=True,
        text=True,
        cwd=REPO,
    )
    return result.stdout if result.returncode == 0 else ""


def parse_ids_lua(content: str) -> tuple[dict[str, int], dict[str, str]]:
    ids: dict[str, int] = {}
    comments: dict[str, str] = {}
    for match in re.finditer(
        r"^\s+([A-Z_0-9#]+)\s*=\s*(\d+),\s*--\s*(.+)$", content, re.M
    ):
        ids[match.group(1)] = int(match.group(2))
        comments[match.group(1)] = match.group(3).strip()
    for match in re.finditer(r"^\s+([A-Z_0-9#]+)\s*=\s*(\d+)(?!,)", content, re.M):
        key = match.group(1)
        if key not in ids:
            ids[key] = int(match.group(2))
    return ids, comments


def rel_path(path: Path) -> str:
    return path.relative_to(REPO).as_posix()


def parse_default_actions(content: str) -> dict[str, dict[str, str]]:
    entries: dict[str, dict[str, str]] = {}
    for match in re.finditer(r"\['([^']+)'\]\s*=\s*\{([^}]+)\}", content):
        name, body = match.group(1), match.group(2)
        event_m = re.search(r"event\s*=\s*(\d+)", body)
        msg_m = re.search(r"messageSpecial\s*=\s*ID\.text\.([A-Z_0-9#]+)", body)
        entries[name] = {
            "event": event_m.group(1) if event_m else "",
            "message_key": msg_m.group(1) if msg_m else "",
        }
    return entries


def scan_external_metalworks_refs() -> list[dict[str, str | int]]:
    rows: list[dict[str, str | int]] = []
    pat = re.compile(
        r"metal(?:worksID|ID)\.text\.([A-Z_0-9#]+)(?:\s*\+\s*(\d+))?"
    )
    for lua_file in sorted((REPO / "scripts").rglob("*.lua")):
        rel = lua_file.relative_to(REPO).as_posix()
        if rel.startswith("scripts/zones/Metalworks/"):
            continue
        content = lua_file.read_text(encoding="utf-8", errors="replace")
        if "METALWORKS" not in content and "metalworksID" not in content and "metalID" not in content:
            continue
        for match in pat.finditer(content):
            key = match.group(1)
            offset = match.group(2) or ""
            ref = f"{key}+{offset}" if offset else key
            rows.append(
                {
                    "Category": "External script",
                    "NPC_or_Entity": "(see mission/quest NPC)",
                    "Source_File": rel,
                    "Reference_Type": "metalworksID.text",
                    "Reference": ref,
                    "Pegasus_Value": "",
                    "LSB_Value": "",
                    "Match": "",
                    "Notes": "Resolved via IDs.lua constant (+ offset if any)",
                }
            )
    return rows


def main() -> None:
    lsb_ids, lsb_comments = parse_ids_lua(git_show(IDS_PATH))
    peg_ids, peg_comments = parse_ids_lua((REPO / IDS_PATH).read_text(encoding="utf-8"))

    rows: list[dict[str, str | int]] = []

    for key in sorted(set(lsb_ids) | set(peg_ids)):
        pv, lv = peg_ids.get(key), lsb_ids.get(key)
        delta = ""
        if pv is not None and lv is not None and pv != lv:
            delta = str(pv - lv)
        sample = peg_comments.get(key) or lsb_comments.get(key) or ""
        rows.append(
            {
                "Category": "IDs.lua",
                "NPC_or_Entity": "(zone constant)",
                "Source_File": "IDs.lua",
                "Reference_Type": "text_constant",
                "Reference": key,
                "Sample_Text": sample,
                "Pegasus_Value": pv if pv is not None else "",
                "LSB_Value": lv if lv is not None else "",
                "Match": "YES" if pv == lv else "NO",
                "Notes": f"Pegasus-LSB={delta}" if delta else "",
            }
        )

    pat_text_key = re.compile(
        r"(?:ID\.text|METALWORKS\]\.text|metalworksID\.text|metalID\.text)\.([A-Z_0-9#]+)"
    )
    pat_showtext = re.compile(r"showText\s*\([^,]+,\s*[^.]+\.text\.([A-Z_0-9#]+)")
    pat_msg_num = re.compile(r"messageSpecial\s*\(\s*(\d+)")
    pat_startevent = re.compile(r"startEvent\s*\(\s*(\d+)")
    pat_progressevent = re.compile(r"progressEvent\s*\(\s*(\d+)")
    pat_def_msg = re.compile(r"messageSpecial\s*=\s*ID\.text\.([A-Z_0-9#]+)")
    pat_def_event = re.compile(r"event\s*=\s*(\d+)")

    def entity_name(file_rel: str) -> str:
        if "/npcs/" in file_rel:
            return Path(file_rel).stem
        return Path(file_rel).stem

    def add_text_ref(
        category: str,
        npc: str,
        source: str,
        ref_type: str,
        key: str,
        notes: str = "",
    ) -> None:
        pv, lv = peg_ids.get(key), lsb_ids.get(key)
        sample = peg_comments.get(key) or lsb_comments.get(key) or ""
        rows.append(
            {
                "Category": category,
                "NPC_or_Entity": npc,
                "Source_File": source,
                "Reference_Type": ref_type,
                "Reference": key,
                "Sample_Text": sample,
                "Pegasus_Value": pv if pv is not None else "MISSING",
                "LSB_Value": lv if lv is not None else "MISSING",
                "Match": "YES" if pv == lv else "NO",
                "Notes": notes,
            }
        )

    def scan_lua(category: str, file_rel: str, content: str, lsb_content: str) -> None:
        npc = entity_name(file_rel)
        scripts_match = content.strip() == lsb_content.strip() if lsb_content else False

        for key in pat_text_key.findall(content):
            add_text_ref(category, npc, file_rel, "ID.text key", key)

        for key in pat_showtext.findall(content):
            add_text_ref(category, npc, file_rel, "showText key", key)

        for num in pat_msg_num.findall(content):
            rows.append(
                {
                    "Category": category,
                    "NPC_or_Entity": npc,
                    "Source_File": file_rel,
                    "Reference_Type": "messageSpecial (raw)",
                    "Reference": num,
                    "Sample_Text": "",
                    "Pegasus_Value": num,
                    "LSB_Value": num if num in pat_msg_num.findall(lsb_content) else "",
                    "Match": "SAME_SCRIPT" if scripts_match else "CHECK_LSB",
                    "Notes": "Hardcoded message ID",
                }
            )

        for num in pat_startevent.findall(content):
            in_lsb = num in pat_startevent.findall(lsb_content) if lsb_content else False
            rows.append(
                {
                    "Category": category,
                    "NPC_or_Entity": npc,
                    "Source_File": file_rel,
                    "Reference_Type": "startEvent",
                    "Reference": num,
                    "Sample_Text": "",
                    "Pegasus_Value": num,
                    "LSB_Value": num if in_lsb else "(not in LSB file)",
                    "Match": "SAME_SCRIPT" if scripts_match else ("YES" if in_lsb else "SCRIPT_DIFF"),
                    "Notes": "Cutscene/event ID (client DAT)",
                }
            )

        for num in pat_progressevent.findall(content):
            rows.append(
                {
                    "Category": category,
                    "NPC_or_Entity": npc,
                    "Source_File": file_rel,
                    "Reference_Type": "progressEvent",
                    "Reference": num,
                    "Sample_Text": "",
                    "Pegasus_Value": num,
                    "LSB_Value": num,
                    "Match": "SAME_SCRIPT" if scripts_match else "CHECK_LSB",
                    "Notes": "Cutscene/event ID (client DAT)",
                }
            )

        if not scripts_match and lsb_content:
            rows.append(
                {
                    "Category": category,
                    "NPC_or_Entity": npc,
                    "Source_File": file_rel,
                    "Reference_Type": "(file summary)",
                    "Reference": "(entire file)",
                    "Sample_Text": "",
                    "Pegasus_Value": "",
                    "LSB_Value": "",
                    "Match": "SCRIPT_DIFF",
                    "Notes": "Lua file differs from LSB upstream/base",
                }
            )

    for lua_file in sorted(ZONE_DIR.rglob("*.lua")):
        file_rel = rel_path(lua_file)
        if file_rel.endswith("IDs.lua"):
            continue
        peg_content = lua_file.read_text(encoding="utf-8", errors="replace")
        lsb_content = git_show(file_rel)
        category = "DefaultActions" if "DefaultActions" in file_rel else "NPC/Zone Script"
        scan_lua(category, file_rel, peg_content, lsb_content)

    da_content = (ZONE_DIR / "DefaultActions.lua").read_text(encoding="utf-8")
    lsb_da = git_show("scripts/zones/Metalworks/DefaultActions.lua")
    peg_da = parse_default_actions(da_content)
    lsb_da_entries = parse_default_actions(lsb_da)

    for name in sorted(set(peg_da) | set(lsb_da_entries)):
        pe = peg_da.get(name, {})
        le = lsb_da_entries.get(name, {})
        pev, lev = pe.get("event", ""), le.get("event", "")
        pmk, lmk = pe.get("message_key", ""), le.get("message_key", "")
        if pev or lev:
            match = "YES" if pev == lev and pev else ("PEGASUS_ONLY" if pev and not lev else ("LSB_ONLY" if lev and not pev else "NO"))
            rows.append(
                {
                    "Category": "DefaultActions",
                    "NPC_or_Entity": name,
                    "Source_File": "DefaultActions.lua",
                    "Reference_Type": "default startEvent",
                    "Reference": f"event {pev or '-'}",
                    "Sample_Text": "",
                    "Pegasus_Value": pev,
                    "LSB_Value": lev,
                    "Match": match,
                    "Notes": "Default CS when no mission/quest override",
                }
            )
        if pmk or lmk:
            key = pmk or lmk
            pv, lv = peg_ids.get(key), lsb_ids.get(key)
            rows.append(
                {
                    "Category": "DefaultActions",
                    "NPC_or_Entity": name,
                    "Source_File": "DefaultActions.lua",
                    "Reference_Type": "default messageSpecial",
                    "Reference": key,
                    "Sample_Text": peg_comments.get(key, lsb_comments.get(key, "")),
                    "Pegasus_Value": pv if pv is not None else "",
                    "LSB_Value": lv if lv is not None else "",
                    "Match": "YES" if pv == lv and pmk == lmk else "NO",
                    "Notes": "",
                }
            )

    if lsb_da.strip() != da_content.strip():
        rows.append(
            {
                "Category": "DefaultActions",
                "NPC_or_Entity": "(file)",
                "Source_File": "DefaultActions.lua",
                "Reference_Type": "(file summary)",
                "Reference": "(entire file)",
                "Sample_Text": "",
                "Pegasus_Value": "",
                "LSB_Value": "",
                "Match": "SCRIPT_DIFF",
                "Notes": "DefaultActions.lua differs from LSB (e.g. Taulluque removed on Pegasus)",
            }
        )

    external_rows = scan_external_metalworks_refs()
    for row in external_rows:
        ref = str(row["Reference"])
        base_key = ref.split("+")[0]
        offset_s = ref.split("+")[1] if "+" in ref else ""
        pv = peg_ids.get(base_key)
        lv = lsb_ids.get(base_key)
        if pv is not None and offset_s:
            pv += int(offset_s)
        if lv is not None and offset_s:
            lv += int(offset_s)
        row["Sample_Text"] = peg_comments.get(base_key, lsb_comments.get(base_key, ""))
        row["Pegasus_Value"] = pv if pv is not None else ""
        row["LSB_Value"] = lv if lv is not None else ""
        row["Match"] = "YES" if pv == lv else "NO"

    out_full = REPO / "tools" / "metalworks_text_id_comparison.csv"
    out_summary = REPO / "tools" / "metalworks_text_id_summary.csv"
    out_external = REPO / "tools" / "metalworks_external_text_refs.csv"
    fields = [
        "Category",
        "NPC_or_Entity",
        "Source_File",
        "Reference_Type",
        "Reference",
        "Sample_Text",
        "Pegasus_Value",
        "LSB_Value",
        "Match",
        "Notes",
    ]

    with out_full.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)

    mismatches = [
        r
        for r in rows
        if r.get("Match") in ("NO", "SCRIPT_DIFF", "CHECK_LSB")
        or (r.get("Category") == "IDs.lua" and r.get("Match") == "NO")
    ]
    with out_summary.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(mismatches)

    with out_external.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(external_rows)

    print(f"Wrote {out_full} ({len(rows)} rows)")
    print(f"Wrote {out_summary} ({len(mismatches)} rows with differences)")
    print(f"Wrote {out_external} ({len(external_rows)} external script references)")


if __name__ == "__main__":
    main()
