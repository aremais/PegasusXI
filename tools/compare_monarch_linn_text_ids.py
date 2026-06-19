#!/usr/bin/env python3
"""Compare Monarch Linn zone text IDs: PegasusXI vs LSB upstream/base."""

import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ZONE = "Monarch_Linn"
ZONE_NUM = 31
ZONE_DIR = REPO / "scripts" / "zones" / ZONE
IDS_PATH = f"scripts/zones/{ZONE}/IDs.lua"
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


def delta_str(peg: int | None, lsb: int | None) -> str:
    if peg is None or lsb is None:
        return "N/A"
    if peg == lsb:
        return "0"
    return f"{peg - lsb:+d}"


def chain_ok(item: int | None, gil: int | None, key: int | None) -> str:
    if item is None or gil is None or key is None:
        return "N/A"
    ok = gil == item + 1 and key == gil + 2
    return "YES" if ok else "NO"


def main() -> None:
    lsb_ids, lsb_comments = parse_ids_lua(git_show(IDS_PATH))
    peg_ids, peg_comments = parse_ids_lua((REPO / IDS_PATH).read_text(encoding="utf-8"))

    print(f"Monarch Linn (zone {ZONE_NUM}) - Text ID comparison")
    print("PegasusXI vs LSB (upstream/base)")
    print()

    print("=== A. IDs.lua constants ===")
    print(f"{'Key':<32} {'Pegasus':>7} {'LSB':>7} {'Delta':>5}  Sample")
    for key in sorted(set(lsb_ids) | set(peg_ids)):
        pv, lv = peg_ids.get(key), lsb_ids.get(key)
        sample = (peg_comments.get(key) or lsb_comments.get(key) or "")[:55]
        print(f"{key:<32} {pv or '-':>7} {lv or '-':>7} {delta_str(pv, lv):>5}  {sample}")

    print()
    print("=== B. Derived obtain-chain IDs ===")
    cannot_p = peg_ids.get("ITEM_CANNOT_BE_OBTAINED")
    cannot_l = lsb_ids.get("ITEM_CANNOT_BE_OBTAINED")
    item_p = peg_ids.get("ITEM_OBTAINED")
    item_l = lsb_ids.get("ITEM_OBTAINED")
    gil_p = peg_ids.get("GIL_OBTAINED")
    gil_l = lsb_ids.get("GIL_OBTAINED")
    key_p = peg_ids.get("KEYITEM_OBTAINED")
    key_l = lsb_ids.get("KEYITEM_OBTAINED")

    derived = []
    if item_p is not None:
        derived.append(("ITEMS_OBTAINED (= ITEM+9)", item_p + 9, (item_l + 9) if item_l else None))
    if cannot_p is not None:
        derived.append(("FULL_INV_AFTER_TRADE (= CANNOT+4)", cannot_p + 4, (cannot_l + 4) if cannot_l else None))
    if key_p is not None:
        derived.append(("KEYITEM_LOST (= KEY+1)", key_p + 1, (key_l + 1) if key_l else None))
        derived.append(("NOT_HAVE_ENOUGH_GIL (= KEY+2)", key_p + 2, (key_l + 2) if key_l else None))
    if item_p is not None and cannot_p is not None:
        derived.append(("ITEM_OBTAINED (= CANNOT+8 check)", item_p, (cannot_l + 8) if cannot_l else None))
    if gil_p is not None and item_p is not None:
        derived.append(("KEYITEM_OBTAINED expected (= GIL+2)", (gil_p + 2) if gil_p else None, (gil_l + 2) if gil_l else None))

    print(f"{'Reference':<42} {'Pegasus':>7} {'LSB':>7} {'Delta':>5}")
    for name, pv, lv in derived:
        print(f"{name:<42} {pv or '-':>7} {lv or '-':>7} {delta_str(pv, lv):>5}")

    print()
    print("=== C. Script references ===")
    refs: dict[str, list[str]] = {}
    pat_text = re.compile(r"(?:ID|monarchLinnID)\.text\.([A-Z_0-9#]+)")
    pat_event = re.compile(r"(?:startEvent|progressEvent)\s*\(\s*(\d+)")

    def add_ref(key: str, source: str) -> None:
        refs.setdefault(key, [])
        if source not in refs[key]:
            refs[key].append(source)

    for lua_file in sorted(ZONE_DIR.rglob("*.lua")):
        rel = lua_file.relative_to(REPO).as_posix()
        if rel.endswith("IDs.lua"):
            continue
        content = lua_file.read_text(encoding="utf-8", errors="replace")
        npc = lua_file.stem
        for match in pat_text.finditer(content):
            add_ref(match.group(1), f"{rel} ({npc})")
        if "npcUtil.giveKeyItem" in content:
            add_ref("KEYITEM_OBTAINED", f"{rel} ({npc}) - npcUtil.giveKeyItem")
        for match in pat_event.finditer(content):
            add_ref(f"EVENT:{match.group(1)}", f"{rel} ({npc})")

    for lua_file in sorted((REPO / "scripts" / "battlefields" / ZONE).glob("*.lua")):
        rel = lua_file.relative_to(REPO).as_posix()
        content = lua_file.read_text(encoding="utf-8", errors="replace")
        for match in pat_text.finditer(content):
            add_ref(match.group(1), rel)
        if "requiredKeyItems" in content:
            add_ref("KEYITEM paths", rel)

    bf_globals = [
        "ENTERING_THE_BATTLEFIELD_FOR",
        "MEMBERS_OF_YOUR_PARTY",
        "MEMBERS_OF_YOUR_ALLIANCE",
        "TIME_LIMIT_FOR_THIS_BATTLE_IS",
        "TIME_IN_THE_BATTLEFIELD_IS_UP",
        "PARTY_MEMBERS_HAVE_FALLEN",
        "THE_PARTY_WILL_BE_REMOVED",
        "PARTY_MEMBERS_ARE_ENGAGED",
        "MEMBERS_LEVELS_ARE_RESTRICTED",
    ]
    for key in bf_globals:
        if key in peg_ids:
            add_ref(key, "scripts/globals/battlefield.lua")

    add_ref("ITEM_OBTAINED", "npcUtil.giveItem / messageItemObtained / mob drops")
    add_ref("ITEM_CANNOT_BE_OBTAINED", "npcUtil.giveItem full inventory")
    add_ref("GIL_OBTAINED", "npcUtil.giveCurrency / giveReward")
    add_ref("KEYITEM_OBTAINED", "npcUtil.giveKeyItem (e.g. Uninvited Guests permit)")
    add_ref("CONQUEST_BASE", "Zone.lua - xi.conquest.onConquestUpdate")

    def sort_key(item: str) -> tuple:
        if item.startswith("EVENT:"):
            return (2, int(item.split(":")[1]))
        if item in peg_ids:
            return (0, peg_ids[item])
        return (1, 0, item)

    for ref in sorted(refs, key=sort_key):
        if ref.startswith("EVENT:"):
            print(f"Event {ref.split(':')[1]:<26} (cutscene ID)")
            continue
        if ref in peg_ids:
            pv, lv = peg_ids[ref], lsb_ids.get(ref)
            src = "; ".join(refs[ref][:3])
            if len(refs[ref]) > 3:
                src += f" (+{len(refs[ref]) - 3} more)"
            print(f"{ref:<32} Peg={pv} LSB={lv} Delta={delta_str(pv, lv):>4}  {src}")
        else:
            print(f"{ref:<32}  {'; '.join(refs[ref][:3])}")

    print()
    print("=== D. Chain validation ===")
    print(f"Pegasus: {chain_ok(item_p, gil_p, key_p)} (ITEM={item_p}, GIL={gil_p}, KEY={key_p})")
    if gil_p == key_p:
        print(f"  ERROR: KEYITEM_OBTAINED ({key_p}) equals GIL_OBTAINED ({gil_p})")
    if key_p is not None and gil_p is not None and key_p != gil_p + 2:
        print(f"  ERROR: KEYITEM_OBTAINED should be {gil_p + 2} (GIL+2), not {key_p}")
    print(f"LSB:     {chain_ok(item_l, gil_l, key_l)} (ITEM={item_l}, GIL={gil_l}, KEY={key_l})")
    if cannot_p and item_p and cannot_p + 8 != item_p:
        print(f"  WARN: Pegasus ITEM_OBTAINED ({item_p}) != CANNOT+8 ({cannot_p + 8})")
    if cannot_l and item_l and cannot_l + 8 != item_l:
        print(f"  WARN: LSB ITEM_OBTAINED ({item_l}) != CANNOT+8 ({cannot_l + 8})")


if __name__ == "__main__":
    main()
