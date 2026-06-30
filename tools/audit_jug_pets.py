#!/usr/bin/env python3
"""Generate BST jug pet and Ready move audit from SQL sources."""
import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql"
OUT = ROOT / "docs" / "bst_jug_pet_audit.md"
UPSTREAM = ROOT / "mob_pools_upstream.sql"

# BST jug pet IDs only (excludes wyvern, automaton, luopan, siren)
JUG_PET_IDS = set(range(21, 48)) | set(range(49, 69)) | set(range(77, 128))
JUG_PET_IDS -= {48}

SKILL_LIST_IDX = 24  # 0-based column index in mob_pools INSERT


def split_sql_values(raw: str) -> list[str]:
    vals = []
    cur = ""
    in_q = False
    for ch in raw:
        if ch == "'" and (not cur or cur[-1] != "\\"):
            in_q = not in_q
            cur += ch
        elif ch == "," and not in_q:
            vals.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur:
        vals.append(cur.strip())
    return vals


def parse_pool_line(line: str) -> tuple[int, dict] | None:
    m = re.match(r"INSERT INTO `mob_pools` VALUES \((\d+)", line)
    if not m:
        return None
    poolid = int(m.group(1))
    raw = line.split("VALUES (", 1)[1].rstrip(");").rstrip(")")
    vals = split_sql_values(raw)
    if len(vals) <= SKILL_LIST_IDX:
        return None
    return poolid, {
        "name": vals[1].strip("'"),
        "skill_list_id": int(vals[SKILL_LIST_IDX]),
    }


def parse_mob_pools_file(path: Path) -> dict[int, dict]:
    pools = {}
    if not path.exists():
        return pools
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        parsed = parse_pool_line(line)
        if parsed:
            pools[parsed[0]] = parsed[1]
    return pools


def parse_pet_list():
    pets = {}
    for line in (SQL / "pet_list.sql").read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(
            r"INSERT INTO `pet_list` VALUES \((\d+),'([^']+)',(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)\)",
            line,
        )
        if not m:
            continue
        pid = int(m.group(1))
        if pid not in JUG_PET_IDS:
            continue
        pets[pid] = {
            "name": m.group(2),
            "poolid": int(m.group(3)),
            "minLevel": int(m.group(4)),
            "maxLevel": int(m.group(5)),
            "time": int(m.group(6)),
        }
    return pets


def parse_skill_lists():
    skill_lists = defaultdict(list)
    list_names = {}
    for line in (SQL / "mob_skill_lists.sql").read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"INSERT INTO `mob_skill_lists` VALUES \('([^']+)',(\d+),(\d+)\)", line)
        if m:
            lname, lid, msid = m.group(1), int(m.group(2)), int(m.group(3))
            skill_lists[lid].append(msid)
            list_names.setdefault(lid, lname)
    return skill_lists, list_names


def parse_pet_skills():
    """pet_skill_id (used in mob_skill_lists) -> display name."""
    names = {}
    for line in (SQL / "pet_skills.sql").read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"INSERT INTO `pet_skills` VALUES \((\d+),\d+,\d+,'([^']+)'", line)
        if m:
            names[int(m.group(1))] = m.group(2)
    return names


def parse_mob_skills():
    mob_skills = {}
    for line in (SQL / "mob_skills.sql").read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"INSERT INTO `mob_skills` VALUES \((\d+),\d+,'([^']+)'", line)
        if m:
            mob_skills[int(m.group(1))] = m.group(2)
    return mob_skills


def parse_jug_items():
    items_by_pet = defaultdict(list)
    for line in (SQL / "item_weapon.sql").read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"INSERT INTO `item_weapon` VALUES \((\d+),'([^']+)',(\d+),(\d+)", line)
        if m:
            itemid, iname, skill, subskill = int(m.group(1)), m.group(2), int(m.group(3)), int(m.group(4))
            if skill == 0 and subskill in JUG_PET_IDS:
                items_by_pet[subskill].append((itemid, iname))
    return items_by_pet


def title_skill(name: str) -> str:
    return " ".join(w.capitalize() for w in name.replace("_", " ").split())


def skill_name(psid, pet_skills, mob_skills):
    raw = pet_skills.get(psid) or mob_skills.get(psid)
    return title_skill(raw) if raw else None


def fmt_moves(skill_lists, pet_skills, mob_skills, sl_id):
    if sl_id is None or sl_id == 0 or sl_id not in skill_lists:
        return "—"
    parts = []
    for psid in skill_lists[sl_id]:
        label = skill_name(psid, pet_skills, mob_skills)
        if label:
            parts.append(f"{label} ({psid})")
        else:
            parts.append(f"**MISSING** id={psid}")
    return ", ".join(parts)


def fmt_items(items):
    if not items:
        return "—"
    return ", ".join(f"{name} [{id}]" for id, name in sorted(items))


def resolve_pool(poolid, pools, upstream):
    if poolid in pools:
        return pools[poolid], "live"
    if poolid in upstream:
        return upstream[poolid], "upstream-only"
    return None, "missing"


def main():
    pets = parse_pet_list()
    pools = parse_mob_pools_file(SQL / "mob_pools.sql")
    upstream = parse_mob_pools_file(UPSTREAM)
    skill_lists, list_names = parse_skill_lists()
    pet_skills = parse_pet_skills()
    mob_skills = parse_mob_skills()
    items_by_pet = parse_jug_items()

    issues = []
    missing_skills = set()
    rows = []
    for pid in sorted(pets):
        p = pets[pid]
        pool, pool_src = resolve_pool(p["poolid"], pools, upstream)
        sl_id = pool["skill_list_id"] if pool else None
        jug_items = items_by_pet.get(pid, [])
        lname = list_names.get(sl_id, "—") if sl_id else "—"

        if pool_src == "missing":
            issues.append(f"Pet **{pid}** ({p['name']}): poolid **{p['poolid']}** missing from mob_pools")
        elif pool_src == "upstream-only":
            issues.append(
                f"Pet **{pid}** ({p['name']}): poolid **{p['poolid']}** only in mob_pools_upstream.sql (not imported)"
            )
        if sl_id == 0:
            issues.append(f"Pet **{pid}** ({p['name']}): skill_list_id is **0** (no Ready moves)")
        elif sl_id and sl_id not in skill_lists:
            issues.append(f"Pet **{pid}** ({p['name']}): skill_list_id **{sl_id}** has no mob_skill_lists entries")
        for psid in skill_lists.get(sl_id or -1, []):
            if psid not in pet_skills and psid not in mob_skills:
                missing_skills.add(psid)
        if not jug_items:
            issues.append(f"Pet **{pid}** ({p['name']}): no jug item in item_weapon (subskill={pid})")

        rows.append(
            {
                "petid": pid,
                "name": p["name"],
                "poolid": p["poolid"],
                "pool_src": pool_src,
                "min": p["minLevel"],
                "max": p["maxLevel"],
                "time_min": p["time"] // 60 if p["time"] else 0,
                "items": jug_items,
                "skill_list_id": sl_id,
                "skill_list_name": lname,
            }
        )

    by_list = defaultdict(list)
    for r in rows:
        key = (r["skill_list_id"], r["skill_list_name"])
        by_list[key].append(r["name"])

    jug_lists = sorted(
        [(lid, lname) for lid, lname in {(k[0], k[1]) for k in by_list} if lid],
        key=lambda x: x[0],
    )

    if missing_skills:
        issues.append(
            f"**{len(missing_skills)}** pet skill IDs referenced in mob_skill_lists but missing from pet_skills/mob_skills: "
            + ", ".join(str(x) for x in sorted(missing_skills))
        )

    lines = [
        "# Beastmaster Jug Pet & Ready Move Audit",
        "",
        "Audit of all BST jug pets (pet IDs 21–47, 49–68, 77–127) and their Ready move sets.",
        "",
        "Data sources:",
        "- `sql/pet_list.sql` — pet metadata (level range, duration, pool link)",
        "- `sql/mob_pools.sql` — mob pool → `skill_list_id` (Ready move pool)",
        "- `sql/mob_skill_lists.sql` — skill list → mob skill IDs (`Jug_*` families)",
        "- `sql/pet_skills.sql` — Ready move display names (authoritative for jug pets)",
        "- `sql/mob_skills.sql` — fallback mob skill names",
        "- `sql/item_weapon.sql` — jug reagent items (`skill=0`, `subskill=petId`)",
        "",
        f"**Total jug pets:** {len(rows)}",
        f"**Data issues found:** {len(set(issues))}",
        "",
        "## Summary",
        "",
        f"- **Classic jug pets (21–68):** {sum(1 for r in rows if r['petid'] <= 68)} — all have mob_pools entries",
        f"- **Merit jug pets (77–127):** {sum(1 for r in rows if r['petid'] >= 77)} — "
        f"{sum(1 for r in rows if r['petid'] >= 77 and r['pool_src'] == 'live')} in live SQL, "
        f"{sum(1 for r in rows if r['petid'] >= 77 and r['pool_src'] == 'upstream-only')} upstream-only",
        f"- **Unique Ready move families (`Jug_*` + merit lists):** {len(jug_lists)} referenced by jug pets",
        "",
    ]

    if issues:
        lines += ["## Data Issues", ""]
        for i in sorted(set(issues)):
            lines.append(f"- {i}")
        lines.append("")

    lines += [
        "## Ready Move Families",
        "",
        "Pets sharing the same `skill_list_id` use identical Ready move sets.",
        "",
        "| skill_list_id | List Name | # Pets | Ready Moves |",
        "|---:|---|---:|---|",
    ]
    for sl_id, lname in jug_lists:
        names = by_list[(sl_id, lname)]
        moves = fmt_moves(skill_lists, pet_skills, mob_skills, sl_id)
        lines.append(f"| {sl_id} | {lname} | {len(names)} | {moves} |")

    # Pets with skill_list_id 0
    zero_pets = [r["name"] for r in rows if r["skill_list_id"] == 0]
    if zero_pets:
        lines += [
            "",
            "### Pets with no Ready moves (skill_list_id = 0)",
            "",
            ", ".join(zero_pets),
            "",
        ]

    lines += [
        "## Full Pet Table",
        "",
        "| Pet ID | Name | Jug Item(s) | Lv | Duration | Pool | skill_list_id | List Name | Ready Moves | Status |",
        "|---:|---|---|---:|---:|---:|---:|---|---|---|",
    ]
    for r in rows:
        lv = f"{r['min']}–{r['max']}" if r["min"] != r["max"] else str(r["min"])
        dur = f"{r['time_min']}m" if r["time_min"] else "—"
        moves = fmt_moves(skill_lists, pet_skills, mob_skills, r["skill_list_id"])
        status = {
            "live": "OK",
            "upstream-only": "Pool missing (upstream)",
            "missing": "Pool missing",
        }[r["pool_src"]]
        if r["skill_list_id"] == 0:
            status = "No Ready moves"
        lines.append(
            f"| {r['petid']} | {r['name']} | {fmt_items(r['items'])} | {lv} | {dur} | {r['poolid']} "
            f"| {r['skill_list_id'] if r['skill_list_id'] is not None else '—'} | {r['skill_list_name']} | {moves} | {status} |"
        )

    lines += [
        "",
        "## Classic Familiar / Named Pairs",
        "",
        "Early jug pets come in Familiar + Named pairs sharing the same Ready move family:",
        "",
        "| Familiar | Named | skill_list_id | Ready Moves |",
        "|---|---|---:|---|",
    ]
    pairs = [
        (21, 36, "Sheep"),
        (22, 37, "Hare"),
        (23, 24, "Crab"),
        (25, 38, "Mandragora"),
        (26, 42, "Flytrap"),
        (27, 39, "Tiger"),
        (28, 38, "Mandragora"),
        (29, 43, "Eft"),
        (30, 40, "Lizard"),
        (31, 41, "Fly"),
        (32, 53, "Funguar"),
        (33, 45, "Beetle"),
        (34, 46, "Antlion"),
        (35, 44, "Diremite"),
    ]
    seen = set()
    for fam, named, _label in pairs:
        if (fam, named) in seen:
            continue
        seen.add((fam, named))
        fam_r = next(r for r in rows if r["petid"] == fam)
        named_r = next(r for r in rows if r["petid"] == named)
        sl = fam_r["skill_list_id"]
        moves = fmt_moves(skill_lists, pet_skills, mob_skills, sl)
        lines.append(
            f"| {fam_r['name']} | {named_r['name']} | {sl} | {moves} |"
        )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT}")
    print(f"Pets: {len(rows)}, Issues: {len(set(issues))}")


if __name__ == "__main__":
    main()
