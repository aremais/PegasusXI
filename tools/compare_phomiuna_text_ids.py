#!/usr/bin/env python3
"""Compare Phomiuna Aqueducts zone text IDs: PegasusXI vs LSB upstream/base."""

import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ZONE = "Phomiuna_Aqueducts"
ZONE_DIR = REPO / "scripts" / "zones" / ZONE
IDS_PATH = f"scripts/zones/{ZONE}/IDs.lua"
LSB_REF = "upstream/base"

FISH_OFFSETS = {
    0x01: "NOROD",
    0x02: "NOBAIT",
    0x03: "CANNOTFISH_MOMENT",
    0x04: "NOCATCH",
    0x05: "MONSTER",
    0x06: "LINEBREAK",
    0x07: "RODBREAK",
    0x08: "HOOKED_SMALL_FISH",
    0x09: "LOST",
    0x0A: "CATCH_INV_FULL",
    0x0E: "CATCH_MULTI",
    0x27: "CATCH",
    0x28: "WARNING",
    0x29: "GOOD_FEELING",
    0x40: "CATCH_CHEST",
}

CONQUEST_OFFSETS = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    31, 32, 33, 34, 35, 36, 37, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55,
]


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


def delta_str(peg: int | None, lsb: int | None) -> str:
    if peg is None or lsb is None:
        return "N/A"
    if peg == lsb:
        return "0"
    return f"{peg - lsb:+d}"


def main() -> None:
    lsb_ids, lsb_comments = parse_ids_lua(git_show(IDS_PATH))
    peg_ids, peg_comments = parse_ids_lua((REPO / IDS_PATH).read_text(encoding="utf-8"))

    print("Phomiuna Aqueducts (zone 27) - Text ID comparison")
    print("PegasusXI vs LSB (upstream/base)")
    print()

    print("=== A. IDs.lua constants (18 keys) ===")
    print(f"{'Key':<32} {'Pegasus':>7} {'LSB':>7} {'Delta':>5}  Usage / sample")
    for key in sorted(set(lsb_ids) | set(peg_ids)):
        pv, lv = peg_ids.get(key), lsb_ids.get(key)
        sample = (peg_comments.get(key) or lsb_comments.get(key) or "")[:55]
        print(f"{key:<32} {pv or '-':>7} {lv or '-':>7} {delta_str(pv, lv):>5}  {sample}")

    print()
    print("=== B. Derived obtain-chain IDs (not in IDs.lua) ===")
    print(f"{'Reference':<42} {'Pegasus':>7} {'LSB':>7} {'Delta':>5}  Trigger")
    derived: list[tuple[str, int | None, int | None, str]] = []

    cannot_p = peg_ids.get("ITEM_CANNOT_BE_OBTAINED")
    cannot_l = lsb_ids.get("ITEM_CANNOT_BE_OBTAINED")
    item_p = peg_ids.get("ITEM_OBTAINED")
    item_l = lsb_ids.get("ITEM_OBTAINED")
    gil_p = peg_ids.get("GIL_OBTAINED")
    gil_l = lsb_ids.get("GIL_OBTAINED")
    key_p = peg_ids.get("KEYITEM_OBTAINED")
    key_l = lsb_ids.get("KEYITEM_OBTAINED")

    if item_p is not None:
        derived.append(("ITEMS_OBTAINED (= ITEM+9)", item_p + 9, (item_l + 9) if item_l else None, "npcUtil.giveItem (multi)"))
    if cannot_p is not None:
        derived.append(("FULL_INV_AFTER_TRADE (= CANNOT+4)", cannot_p + 4, (cannot_l + 4) if cannot_l else None, "npcUtil.giveItem fromTrade"))
    if key_p is not None:
        derived.append(("KEYITEM_LOST (= KEY+1)", key_p + 1, (key_l + 1) if key_l else None, "conquest KEYITEM_LOST"))
        derived.append(("NOT_HAVE_ENOUGH_GIL (= KEY+2)", key_p + 2, (key_l + 2) if key_l else None, "obtain chain slot"))
    if gil_p is not None and item_p is not None:
        derived.append(("GIL (= ITEM+1 chain check)", gil_p, gil_l, "npcUtil / messageItemObtained"))

    for name, pv, lv, note in derived:
        print(f"{name:<42} {pv or '-':>7} {lv or '-':>7} {delta_str(pv, lv):>5}  {note}")

    print()
    print("=== C. LAMP_OFFSET + 0..7 (element lamp NPCs) ===")
    print(f"{'Reference':<20} {'Pegasus':>7} {'LSB':>7} {'Delta':>5}  Element")
    elements = ["Fire", "Earth", "Water", "Wind", "Ice", "Thunder", "Light", "Dark"]
    base_p = peg_ids.get("LAMP_OFFSET")
    base_l = lsb_ids.get("LAMP_OFFSET")
    for i, elem in enumerate(elements):
        pv = base_p + i if base_p is not None else None
        lv = base_l + i if base_l is not None else None
        print(f"LAMP_OFFSET+{i:<13} {pv or '-':>7} {lv or '-':>7} {delta_str(pv, lv):>5}  {elem} lamp")

    print()
    print("=== D. Script references by text ID ===")
    refs: dict[str, list[str]] = {}

    def add_ref(key: str, source: str) -> None:
        refs.setdefault(key, [])
        if source not in refs[key]:
            refs[key].append(source)

    pat_text = re.compile(r"ID\.text\.([A-Z_0-9#]+)(?:\s*\+\s*(\d+))?")
    pat_event = re.compile(
        r"(?:startEvent|progressEvent|startOptionalCutscene)\s*\(\s*(\d+)"
    )

    for lua_file in sorted(ZONE_DIR.rglob("*.lua")):
        rel = lua_file.relative_to(REPO).as_posix()
        if rel.endswith("IDs.lua"):
            continue
        content = lua_file.read_text(encoding="utf-8", errors="replace")
        npc = lua_file.stem
        for match in pat_text.finditer(content):
            key, off = match.group(1), match.group(2) or ""
            ref = f"{key}+{off}" if off else key
            add_ref(ref, f"{rel} ({npc})")
        if "npcUtil.giveKeyItem" in content:
            add_ref("KEYITEM_OBTAINED", f"{rel} ({npc}) — npcUtil.giveKeyItem")
        for match in pat_event.finditer(content):
            add_ref(f"EVENT:{match.group(1)}", f"{rel} ({npc})")

    for lua_file in sorted((REPO / "scripts").rglob("*.lua")):
        rel = lua_file.relative_to(REPO).as_posix()
        if rel.startswith(f"scripts/zones/{ZONE}/"):
            continue
        content = lua_file.read_text(encoding="utf-8", errors="replace")
        if "PHOMIUNA_AQUEDUCTS" not in content:
            continue
        if "[xi.zone.PHOMIUNA_AQUEDUCTS]" not in content:
            continue
        for match in re.finditer(r"progressEvent\s*\(\s*(\d+)", content):
            add_ref(f"EVENT:{match.group(1)}", f"{rel}")
        if "quest:keyItem" in content:
            add_ref("KEYITEM_OBTAINED", f"{rel} — quest:keyItem")

    add_ref("COMMON_SENSE_SURVIVAL", "scripts/globals/teleports/survival_guide.lua (Survival_Guide NPC)")
    add_ref("CONQUEST_BASE", "scripts/zones/Phomiuna_Aqueducts/Zone.lua — xi.conquest.onConquestUpdate")
    add_ref("ITEM_OBTAINED", "npcUtil / messageItemObtained — mob drops, quest rewards in zone")
    add_ref("ITEM_CANNOT_BE_OBTAINED", "npcUtil.giveItem — inventory full")
    add_ref("GIL_OBTAINED", "npcUtil.giveReward — gil rewards")
    add_ref("FISHING_MESSAGE_OFFSET", "fishingutils.cpp — all fishing in zone")

    def sort_key(item: str) -> tuple:
        if item.startswith("EVENT:"):
            return (2, int(item.split(":")[1]))
        base = item.split("+")[0]
        off = int(item.split("+")[1]) if "+" in item else 0
        if base in peg_ids:
            return (0, peg_ids[base] + off)
        return (1, item)

    for ref in sorted(refs, key=sort_key):
        base = ref.split("+")[0]
        off_s = ref.split("+")[1] if "+" in ref and not ref.startswith("EVENT:") else None
        if ref.startswith("EVENT:"):
            peg_val = lsb_val = ref.split(":")[1]
            print(f"Event {peg_val:<28} (cutscene ID, not zone text slot)")
        elif base in peg_ids:
            off = int(off_s) if off_s else 0
            pv = peg_ids[base] + off
            lv = lsb_ids[base] + off
            sources = "; ".join(refs[ref][:3])
            if len(refs[ref]) > 3:
                sources += f" (+{len(refs[ref]) - 3} more)"
            print(f"{ref:<28} Peg={pv} LSB={lv} Delta={delta_str(pv, lv):>4}  {sources}")
        else:
            print(f"{ref:<28}  { '; '.join(refs[ref][:3]) }")

    print()
    print("=== E. Engine / global paths (zone-aware while in Phomiuna) ===")
    engine = [
        ("ITEM_OBTAINED / ITEMS_OBTAINED", "src/map/lua/lua_baseentity.cpp — messageItemObtained()"),
        ("KEYITEM_OBTAINED", "src/map/entities/charentity.cpp — moghancement KI"),
        ("FISHING_MESSAGE_OFFSET + offsets", "src/map/utils/fishingutils.cpp"),
        ("CONQUEST_BASE + offsets", "scripts/globals/conquest.lua — zone conquest tally"),
    ]
    for keys, path in engine:
        print(f"  {keys}: {path}")

    print()
    print("Obtain-chain rule (audit): GIL=ITEM+1, KEY=GIL+2, KEY_LOST=KEY+1, ITEMS=ITEM+9")
    if item_p and gil_p and key_p:
        ok = gil_p == item_p + 1 and key_p == gil_p + 2
        print(f"Pegasus chain valid: {'YES' if ok else 'NO'} (ITEM={item_p}, GIL={gil_p}, KEY={key_p})")
    if item_l and gil_l and key_l:
        ok = gil_l == item_l + 1 and key_l == gil_l + 2
        print(f"LSB chain valid:     {'YES' if ok else 'NO'} (ITEM={item_l}, GIL={gil_l}, KEY={key_l})")


if __name__ == "__main__":
    main()
