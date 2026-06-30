"""Generate southern_sandoria_npc_textids.csv from codebase sources."""
import csv
import re
from pathlib import Path

base = Path(r"c:\PegasusXI\server")
ids_file = base / "scripts/zones/Southern_San_dOria/IDs.lua"
default_file = base / "scripts/zones/Southern_San_dOria/DefaultActions.lua"
npc_sql = base / "sql/npc_list.sql"
npc_dir = base / "scripts/zones/Southern_San_dOria/npcs"
shop_file = base / "scripts/globals/shop.lua"
out_csv = base / "tools/southern_sandoria_npc_textids.csv"

# DefaultActions keys that differ from npc_list script names
DEFAULT_ACTION_ALIASES = {
    "Enigmatic_Footprints": "Enigmatic Footprints",
}

# --- IDs.lua ---
text_map = {}
ids_content = ids_file.read_text(encoding="utf-8")
text_block = re.search(r"text\s*=\s*\{(.*?)\n\s*\},", ids_content, re.S)
if text_block:
    for m in re.finditer(r"(\w+)\s*=\s*(-?\d+|\d+),", text_block.group(1)):
        text_map[m.group(1)] = int(m.group(2))

# --- DefaultActions ---
default_actions = {}
for m in re.finditer(r"\['([^']+)'\]\s*=\s*\{([^}]+)\}", default_file.read_text(encoding="utf-8")):
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


def lookup_default_action(script_name):
    if script_name in default_actions:
        return default_actions[script_name]
    alias = DEFAULT_ACTION_ALIASES.get(script_name)
    if alias and alias in default_actions:
        return default_actions[alias]
    return None


# --- Regional shop ---
regional_shop = {}
for m in re.finditer(
    r"\['(\w+)'\s*\]\s*=\s*\{[^}]*southSandyID\.text\.(\w+),\s*southSandyID\.text\.(\w+)",
    shop_file.read_text(encoding="utf-8"),
):
    npc, open_key, closed_key = m.group(1), m.group(2), m.group(3)
    regional_shop[npc] = {
        "open": text_map.get(open_key),
        "open_key": open_key,
        "closed": text_map.get(closed_key),
        "closed_key": closed_key,
    }


def parse_npc_insert(line):
    """Parse npc_list INSERT; handles escaped apostrophes and unquoted hex script names."""
    m = re.search(
        r"VALUES \((\d+),(?:'((?:[^'\\]|\\.)*)'|([^,' ]+)),'((?:[^'\\]|\\.)*)',(\d+),",
        line,
    )
    if not m:
        return None
    script = (m.group(2) or m.group(3) or "").replace("\\'", "'")
    return {
        "npcid": int(m.group(1)),
        "script": script,
        "display": m.group(4).replace("\\'", "'"),
        "pos_rot": int(m.group(5)),
    }


def extract_function_block(content, func_name):
    marker = f"entity.{func_name} = function"
    start = content.find(marker)
    if start < 0:
        return None
    body_start = content.find("\n", start) + 1
    depth = 0
    i = body_start
    while i < len(content):
        if content.startswith("function", i):
            depth += 1
        elif content.startswith("end", i) and not content[i + 3 : i + 4].isalnum():
            if depth == 0:
                return content[body_start:i]
            depth -= 1
        i += 1
    return None


def parse_trigger_block(block):
    texts, keys, events = [], [], []
    if not block:
        return texts, keys, events

    for m in re.finditer(
        r"showText\([^,]+,\s*ID\.text\.(\w+)(?:\s*\+\s*(\d+))?",
        block,
    ):
        key = m.group(1)
        offset = int(m.group(2) or 0)
        if key in text_map:
            texts.append(text_map[key] + offset)
            keys.append(f"{key}{'+' + str(offset) if offset else ''}")

    for m in re.finditer(
        r"(?:messageText|messageSpecial)\([^,]+,\s*ID\.text\.(\w+)",
        block,
    ):
        key = m.group(1)
        if key in text_map:
            texts.append(text_map[key])
            keys.append(key)

    for m in re.finditer(
        r"(?:messageText|messageSpecial)\([^,]+,\s*(\d+)",
        block,
    ):
        texts.append(int(m.group(1)))
        keys.append(m.group(1))

    for m in re.finditer(
        r"(?:messageText|messageSpecial)\([^)]*ID\.text\.(\w+)",
        block,
    ):
        key = m.group(1)
        if key in text_map and text_map[key] not in texts:
            texts.append(text_map[key])
            keys.append(key)

    for m in re.finditer(r"startEvent\((\d+)", block):
        events.append(int(m.group(1)))

    for m in re.finditer(r"guildPointOnTrigger\([^,]+,\s*(\d+)", block):
        events.insert(0, int(m.group(1)))

    for m in re.finditer(r"xi\.homepoint\.onTrigger\([^,]+,\s*(\d+)", block):
        events.insert(0, int(m.group(1)))

    # hpEvent = 8700 style globals passed to xi.homepoint.onTrigger
    hm = re.search(r"local hpEvent = (\d+)", block)
    if hm:
        events.insert(0, int(hm.group(1)))

    # dedupe preserving order
    def dedupe_pairs(ts, ks):
        seen = set()
        out_t, out_k = [], []
        for t, k in zip(ts, ks):
            if t not in seen and t != 0:
                seen.add(t)
                out_t.append(t)
                out_k.append(k)
        return out_t, out_k

    texts, keys = dedupe_pairs(texts, keys)
    events = list(dict.fromkeys(events))
    return texts, keys, events


def parse_trade_block(block):
    texts, keys = [], []
    if not block:
        return texts, keys
    for m in re.finditer(r"ID\.text\.(\w+)", block):
        key = m.group(1)
        if key in text_map:
            texts.append(text_map[key])
            keys.append(key)
    seen = set()
    out_t, out_k = [], []
    for t, k in zip(texts, keys):
        if t not in seen:
            seen.add(t)
            out_t.append(t)
            out_k.append(k)
    return out_t, out_k


def parse_event_finish_block(block):
    texts, keys = [], []
    if not block:
        return texts, keys
    for m in re.finditer(r"ID\.text\.(\w+)", block):
        key = m.group(1)
        if key in text_map:
            texts.append(text_map[key])
            keys.append(key)
    return texts, keys


# --- npc_list zone 230 ---
npc_rows = []
in_zone = False
unparsed = 0
for line in npc_sql.read_text(encoding="utf-8", errors="replace").splitlines():
    if "Southern San d'Oria (Zone 230)" in line:
        in_zone = True
        continue
    if in_zone and line.startswith("-- ") and "Northern San d'Oria (Zone 231)" in line:
        break
    if in_zone and line.startswith("INSERT"):
        parsed = parse_npc_insert(line)
        if parsed:
            npc_rows.append(parsed)
        else:
            unparsed += 1

# --- NPC scripts ---
script_info = {}
for f in npc_dir.glob("*.lua"):
    content = f.read_text(encoding="utf-8", errors="replace")
    trigger = extract_function_block(content, "onTrigger")
    trade = extract_function_block(content, "onTrade")
    finish = extract_function_block(content, "onEventFinish")

    t_texts, t_keys, t_events = parse_trigger_block(trigger)
    trade_texts, trade_keys = parse_trade_block(trade)
    finish_texts, finish_keys = parse_event_finish_block(finish)

    script_info[f.stem] = {
        "has_onTrigger": trigger is not None,
        "trigger_texts": t_texts,
        "trigger_text_keys": t_keys,
        "trigger_events": t_events,
        "trade_texts": trade_texts,
        "trade_text_keys": trade_keys,
        "finish_texts": finish_texts,
        "finish_text_keys": finish_keys,
        "uses_regional_shop": "handleRegionalShop" in (trigger or ""),
        "uses_valeriano_shop": "handleValerianoShop" in (trigger or ""),
        "uses_print_to_player": trigger and "printToPlayer" in trigger,
    }

rows = []
for npc in npc_rows:
    script = npc["script"]
    info = script_info.get(script, {})
    da = lookup_default_action(script)

    primary_text = None
    primary_key = None
    primary_event = None
    alt_texts, alt_keys = [], []
    alt_events = []
    trade_texts, trade_keys = info.get("trade_texts", []), info.get("trade_text_keys", [])
    notes = []

    # 1) Regional shop (onTrigger)
    if script in regional_shop:
        rs = regional_shop[script]
        primary_text = rs["open"]
        primary_key = rs["open_key"]
        if rs["closed"] is not None:
            alt_texts.append(rs["closed"])
            alt_keys.append(rs["closed_key"])
        notes.append("regional shop")

    # 2) Valeriano shop
    elif script == "Valeriano" or info.get("uses_valeriano_shop"):
        primary_text = text_map.get("VALERIANO_SHOP_DIALOG")
        primary_key = "VALERIANO_SHOP_DIALOG"
        notes.append("valeriano shop")

    # 3) onTrigger texts (preferred over events)
    elif info.get("trigger_texts"):
        primary_text = info["trigger_texts"][0]
        primary_key = info["trigger_text_keys"][0]
        alt_texts.extend(info["trigger_texts"][1:])
        alt_keys.extend(info["trigger_text_keys"][1:])
        notes.append("script onTrigger")

    # 4) DefaultActions text when script has no onTrigger handler
    elif da and "text_key" in da and not info.get("has_onTrigger"):
        primary_text = text_map.get(da["text_key"])
        primary_key = da["text_key"]
        notes.append("default")

    # 5) DefaultActions messageSpecial via alias (Enigmatic Footprints)
    elif da and "text_key" in da:
        primary_text = text_map.get(da["text_key"])
        primary_key = da["text_key"]
        notes.append("default")

    # 6) onTrigger events
    if primary_text is None and info.get("trigger_events"):
        primary_event = info["trigger_events"][0]
        alt_events = info["trigger_events"][1:]
        notes.append("script onTrigger event")

    # 7) DefaultActions event fallback
    if primary_text is None and primary_event is None and da and "event" in da:
        primary_event = da["event"]
        notes.append("default event")

    # onTrigger may also fire events alongside text (e.g. qm3)
    if info.get("trigger_events"):
        for ev in info["trigger_events"]:
            if ev != primary_event and ev not in alt_events:
                alt_events.append(ev)

    # Trade / event-finish texts are never primary; record separately in alt if useful
    for t, k in zip(trade_texts, trade_keys):
        if t != primary_text and t not in alt_texts:
            pass  # goes to trade_text_ids column
    for t, k in zip(info.get("finish_texts", []), info.get("finish_text_keys", [])):
        if t != primary_text and t not in alt_texts:
            pass  # goes to event_finish_text_ids column

    if (
        primary_text is None
        and primary_event is None
        and info.get("uses_print_to_player")
    ):
        notes.append("printToPlayer only")

    if (
        primary_text is None
        and primary_event is None
        and not notes
    ):
        notes.append("no default text/event")

    rows.append(
        {
            "display_name": npc["display"] or script,
            "script_name": script,
            "npc_id": npc["npcid"],
            "primary_text_id": primary_text if primary_text is not None else "",
            "primary_text_key": primary_key or "",
            "primary_event_id": primary_event if primary_event is not None else "",
            "alt_text_ids": "; ".join(str(t) for t in alt_texts),
            "alt_text_keys": "; ".join(alt_keys),
            "alt_event_ids": "; ".join(str(e) for e in alt_events),
            "trade_text_ids": "; ".join(str(t) for t in trade_texts),
            "trade_text_keys": "; ".join(trade_keys),
            "event_finish_text_ids": "; ".join(
                str(t) for t in info.get("finish_texts", [])
            ),
            "event_finish_text_keys": "; ".join(info.get("finish_text_keys", [])),
            "notes": "; ".join(dict.fromkeys(notes)),
        }
    )

fieldnames = [
    "display_name",
    "script_name",
    "npc_id",
    "primary_text_id",
    "primary_text_key",
    "primary_event_id",
    "alt_text_ids",
    "alt_text_keys",
    "alt_event_ids",
    "trade_text_ids",
    "trade_text_keys",
    "event_finish_text_ids",
    "event_finish_text_keys",
    "notes",
]

with out_csv.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(sorted(rows, key=lambda r: (r["display_name"].lower(), r["npc_id"])))

with_text = sum(1 for r in rows if r["primary_text_id"])
with_event = sum(1 for r in rows if r["primary_event_id"])
print(f"Wrote {len(rows)} rows to {out_csv}")
print(f"SQL unparsed lines: {unparsed}")
print(f"Rows with primary TextID: {with_text}")
print(f"Rows with primary EventID: {with_event}")

# Spot-check fixed rows
checks = {
    17719317: ("8258", "", "Benaige"),
    17719387: ("8258", "", "Miogique"),
    17719534: ("", "683", "Nokkhi"),
    17719535: ("", "759", "Ominous Cloud"),
    17719548: ("", "690", "Alivatand"),
    17719569: ("", "812", "Amutiyaal"),
    17719422: ("", "", "Ailevia"),
    17719392: ("", "525", "Varchet"),
    17720029: ("16531", "", "Enigmatic Footprints"),
}
print("\nSpot checks:")
for nid, (exp_text, exp_event, label) in checks.items():
    row = next(r for r in rows if r["npc_id"] == nid)
    ok = str(row["primary_text_id"]) == exp_text and str(row["primary_event_id"]) == exp_event
    status = "OK" if ok else "FAIL"
    print(
        f"  [{status}] {label}: text={row['primary_text_id']} event={row['primary_event_id']}"
    )
