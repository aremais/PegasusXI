"""Audit southern_sandoria_npc_textids.csv against live codebase."""
import csv
import re
from pathlib import Path

base = Path(r"c:\PegasusXI\server")
csv_path = base / "tools/southern_sandoria_npc_textids.csv"
ids_file = base / "scripts/zones/Southern_San_dOria/IDs.lua"
default_file = base / "scripts/zones/Southern_San_dOria/DefaultActions.lua"
npc_dir = base / "scripts/zones/Southern_San_dOria/npcs"
shop_file = base / "scripts/globals/shop.lua"
npc_sql = base / "sql/npc_list.sql"

issues = []

def add(severity, category, row, message):
    issues.append({
        "severity": severity,
        "category": category,
        "display": row.get("display_name", ""),
        "script": row.get("script_name", ""),
        "npc_id": row.get("npc_id", ""),
        "message": message,
    })

# Parse IDs.lua
text_map = {}
ids_content = ids_file.read_text(encoding="utf-8")
text_block = re.search(r"text\s*=\s*\{(.*?)\n\s*\},", ids_content, re.S)
if text_block:
    for m in re.finditer(r"(\w+)\s*=\s*(-?\d+|\d+),", text_block.group(1)):
        text_map[m.group(1)] = int(m.group(2))

# DefaultActions
default_actions = {}
da_content = default_file.read_text(encoding="utf-8")
for m in re.finditer(r"\['([^']+)'\]\s*=\s*\{([^}]+)\}", da_content):
    name, body = m.group(1), m.group(2)
    entry = {}
    em = re.search(r"event\s*=\s*(-?\d+)", body)
    if em:
        entry["event"] = int(em.group(1))
    tm = re.search(r"text\s*=\s*ID\.text\.(\w+)", body)
    if tm:
        entry["text_key"] = tm.group(1)
    tm2 = re.search(r"messageSpecial\s*=\s*ID\.text\.(\w+)", body)
    if tm2:
        entry["text_key"] = tm2.group(1)
    default_actions[name] = entry

# Regional shop
regional_shop = {}
for m in re.finditer(
    r"\['(\w+)'\s*\]\s*=\s*\{[^}]*southSandyID\.text\.(\w+),\s*southSandyID\.text\.(\w+)",
    shop_file.read_text(encoding="utf-8"),
):
    regional_shop[m.group(1)] = (m.group(2), m.group(3))

# npc_list zone 230 npcids
sql_npcids = set()
in_zone = False
for line in npc_sql.read_text(encoding="utf-8", errors="replace").splitlines():
    if "Southern San d'Oria (Zone 230)" in line:
        in_zone = True
        continue
    if in_zone and line.startswith("-- ") and "Northern San d'Oria (Zone 231)" in line:
        break
    if in_zone and line.startswith("INSERT"):
        m = re.search(r"VALUES \((\d+),", line)
        if m:
            sql_npcids.add(int(m.group(1)))

# Parse each NPC script in detail
script_info = {}
for f in npc_dir.glob("*.lua"):
    name = f.stem
    content = f.read_text(encoding="utf-8", errors="replace")
    info = {
        "has_onTrigger": "entity.onTrigger" in content,
        "trigger_texts": [],
        "trigger_text_keys": [],
        "trigger_events": [],
        "trade_texts": [],
        "other_texts": [],
        "uses_regional_shop": "handleRegionalShop" in content,
        "uses_valeriano_shop": "handleValerianoShop" in content,
        "showtext_plus_one": bool(re.search(r"showText\([^,]+,\s*ID\.text\.\w+\s*\+\s*1", content)),
    }

    trigger_block = re.search(r"entity\.onTrigger\s*=\s*function[\s\S]*?^end", content, re.M)
    trade_block = re.search(r"entity\.onTrade\s*=\s*function[\s\S]*?^end", content, re.M)

    def extract_texts(block, dest_keys, dest_ids):
        if not block:
            return
        for m in re.finditer(r"ID\.text\.(\w+)", block.group(0)):
            k = m.group(1)
            if k in text_map:
                dest_keys.append(k)
                dest_ids.append(text_map[k])
        for m in re.finditer(r"showText\([^,]+,\s*(\d+)", block.group(0)):
            dest_ids.append(int(m.group(1)))
            dest_keys.append(str(m.group(1)))
        for m in re.finditer(r"startEvent\((\d+)", block.group(0)):
            info["trigger_events"].append(int(m.group(1)))

    extract_texts(trigger_block, info["trigger_text_keys"], info["trigger_texts"])
    extract_texts(trade_block, [], info["trade_texts"])

    # +1 offset
    if info["showtext_plus_one"]:
        m = re.search(r"showText\([^,]+,\s*ID\.text\.(\w+)\s*\+\s*1", content)
        if m:
            base_key = m.group(1)
            if base_key in text_map:
                info["trigger_texts"] = [text_map[base_key] + 1]
                info["trigger_text_keys"] = [f"{base_key}+1"]

    script_info[name] = info

script_files = {f.stem for f in npc_dir.glob("*.lua")}

rows = list(csv.DictReader(csv_path.open(encoding="utf-8")))
csv_npcids = set()
csv_scripts = set()

for row in rows:
    script = row["script_name"]
    csv_scripts.add(script)
    if row["npc_id"]:
        nid = int(row["npc_id"])
        csv_npcids.add(nid)
        if nid not in sql_npcids:
            add("ERROR", "npc_id", row, f"NPC ID {nid} not found in npc_list.sql zone 230 section")

    # primary key vs ID value mismatch
    if row["primary_text_key"] and row["primary_text_id"]:
        key = row["primary_text_key"]
        tid = int(row["primary_text_id"])
        if key in text_map and text_map[key] != tid:
            add("ERROR", "key_mismatch", row,
                f"primary_text_key {key} maps to {text_map[key]} in IDs.lua, but CSV says {tid}")
        if key.isdigit() and int(key) != tid:
            add("WARN", "hardcoded", row, f"Hardcoded text ID {key} - not in IDs.lua enum")

    # alt keys mismatch
    if row["alt_text_keys"] and row["alt_text_ids"]:
        alt_keys = [k.strip() for k in row["alt_text_keys"].split(";")]
        alt_ids = [int(x.strip()) for x in row["alt_text_ids"].split(";")]
        for k, tid in zip(alt_keys, alt_ids):
            if k in text_map and text_map[k] != tid:
                add("ERROR", "alt_key_mismatch", row,
                    f"alt key {k} maps to {text_map[k]}, CSV alt says {tid}")

    info = script_info.get(script)
    if info and info["has_onTrigger"]:
        # Script has onTrigger but CSV says no default text and no event in notes
        if not row["primary_text_id"] and "event" not in row["notes"]:
            add("WARN", "missing_handler", row,
                "Has onTrigger script but CSV shows no text ID and no event in notes")

        # Primary text from trade block only
        if row["primary_text_id"] and info["trigger_texts"]:
            primary = int(row["primary_text_id"])
            if primary not in info["trigger_texts"] and primary in info["trade_texts"]:
                add("WARN", "trade_as_primary", row,
                    f"Primary text {primary} comes from onTrade, not onTrigger "
                    f"(onTrigger texts: {info['trigger_texts']})")

        if row["primary_text_id"] and not info["trigger_texts"] and info["trade_texts"]:
            primary = int(row["primary_text_id"])
            if primary in info["trade_texts"]:
                add("WARN", "trade_only_primary", row,
                    f"Primary text {primary} only appears in onTrade; onTrigger uses event(s) "
                    f"{info['trigger_events'] or 'none'}")

        # Wrong primary vs onTrigger first text
        if info["trigger_texts"] and row["primary_text_id"]:
            expected = info["trigger_texts"][0]
            actual = int(row["primary_text_id"])
            if actual != expected and script not in regional_shop:
                # regional shop overrides script (empty trigger)
                if not (script in default_actions and "text_key" in default_actions[script]
                          and text_map.get(default_actions[script]["text_key"]) == actual):
                    add("WARN", "wrong_primary", row,
                        f"onTrigger first text is {expected} ({info['trigger_text_keys'][0]}), "
                        f"CSV primary is {actual}")

        # Event in notes vs script
        if info["trigger_events"]:
            note_events = [int(x) for x in re.findall(r"event (\d+)", row["notes"])]
            for ev in info["trigger_events"]:
                if ev not in note_events and not row["primary_text_id"]:
                    add("WARN", "missing_event_note", row,
                        f"Script onTrigger uses event {ev} but notes don't include it: {row['notes']}")
            for ev in note_events:
                if ev not in info["trigger_events"] and script in default_actions:
                    da_ev = default_actions[script].get("event")
                    if ev == da_ev and da_ev not in info["trigger_events"]:
                        pass  # default event, script may override - OK
                    elif ev not in info["trigger_events"]:
                        add("INFO", "default_event_only", row,
                            f"Notes list event {ev} from DefaultActions but script onTrigger uses "
                            f"{info['trigger_events'] or 'text instead'}")

    # DefaultActions text but CSV empty
    if script in default_actions and "text_key" in default_actions[script]:
        dk = default_actions[script]["text_key"]
        expected = text_map.get(dk)
        if not row["primary_text_id"]:
            add("ERROR", "missing_default_text", row,
                f"DefaultActions defines text {dk} ({expected}) but CSV has no primary text")
        elif int(row["primary_text_id"]) != expected:
            add("WARN", "default_text_override", row,
                f"DefaultActions text is {dk} ({expected}) but CSV primary is {row['primary_text_id']}")

    # Regional shop NPC missing regional note or wrong text
    if script in regional_shop:
        open_key, closed_key = regional_shop[script]
        expected_open = text_map[open_key]
        if not row["primary_text_id"]:
            add("ERROR", "regional_shop", row, f"Regional vendor missing open text {open_key} ({expected_open})")
        elif int(row["primary_text_id"]) != expected_open:
            add("ERROR", "regional_shop", row,
                f"Expected open text {expected_open} ({open_key}), got {row['primary_text_id']}")
        if "regional shop" not in row["notes"]:
            add("INFO", "notes", row, "Regional shop NPC but notes don't say 'regional shop'")

    if script == "Valeriano":
        expected = text_map["VALERIANO_SHOP_DIALOG"]
        if row["primary_text_id"] and int(row["primary_text_id"]) != expected:
            add("ERROR", "valeriano", row, f"Expected VALERIANO_SHOP_DIALOG {expected}")

    # Suspicious values
    if row["primary_text_id"] and int(row["primary_text_id"]) >= 1000000:
        add("WARN", "suspicious", row, f"Unusually large text ID {row['primary_text_id']} - likely debug/test code")

    if row["primary_text_id"] == "0" or row["alt_text_ids"] == "0":
        add("WARN", "zero_text", row, "Text ID 0 is a fallback/null and not a real message")

    # Conflicting notes
    if "no default text" in row["notes"] and row["primary_text_id"]:
        add("ERROR", "contradiction", row, "Notes say 'no default text' but primary_text_id is set")

    if "event" in row["notes"] and row["primary_text_id"] and script not in ("Varchet",):
        # Many NPCs use event OR text depending on state - only flag if default_actions is event-only
        if script in default_actions and "text_key" not in default_actions[script] and "event" in default_actions[script]:
            if script not in script_info or not script_info[script]["trigger_texts"]:
                pass  # event only OK
            elif script in ("qm3", "Rolandienne", "Gondebaud"):
                pass  # conditional text+event
            elif "script" in row["notes"] and "default" not in row["notes"]:
                add("INFO", "text_and_event", row,
                    "Has both primary text and event notes - may be conditional logic")

# Scripts on disk not represented
for s in sorted(script_files - csv_scripts):
    add("ERROR", "missing_from_csv", {"script_name": s, "display_name": s, "npc_id": ""},
        f"NPC script {s}.lua exists but no CSV row with that script_name")

# Duplicate npc_ids
from collections import Counter
id_counts = Counter(r["npc_id"] for r in rows if r["npc_id"])
for nid, count in id_counts.items():
    if count > 1:
        add("ERROR", "duplicate_npc_id", {"npc_id": nid, "display_name": "", "script_name": ""},
            f"NPC ID {nid} appears {count} times in CSV")

# Missing npc_ids from sql
missing_from_csv = sql_npcids - csv_npcids
if missing_from_csv:
    add("ERROR", "coverage", {"npc_id": "", "display_name": "", "script_name": ""},
        f"{len(missing_from_csv)} npc_list.sql zone-230 IDs missing from CSV: "
        f"{sorted(missing_from_csv)[:10]}{'...' if len(missing_from_csv) > 10 else ''}")

extra_in_csv = csv_npcids - sql_npcids
if extra_in_csv:
    add("ERROR", "coverage", {"npc_id": "", "display_name": "", "script_name": ""},
        f"{len(extra_in_csv)} CSV npc_ids not in zone 230 sql: {sorted(extra_in_csv)}")

# Print report
by_sev = {"ERROR": [], "WARN": [], "INFO": []}
for i in issues:
    by_sev[i["severity"]].append(i)

print(f"Audited {len(rows)} CSV rows against codebase")
print(f"ERROR: {len(by_sev['ERROR'])}  WARN: {len(by_sev['WARN'])}  INFO: {len(by_sev['INFO'])}")
print()

for sev in ("ERROR", "WARN", "INFO"):
    if not by_sev[sev]:
        continue
    print(f"=== {sev} ({len(by_sev[sev])}) ===")
    for i in by_sev[sev]:
        loc = i["script"]
        if i["npc_id"]:
            loc += f" ({i['npc_id']})"
        if i["display"] and i["display"] != i["script"]:
            loc = f"{i['display']} / {loc}"
        print(f"  [{i['category']}] {loc}")
        print(f"    {i['message']}")
    print()
