#!/usr/bin/env python3
"""
Spreads SKCNM Tier II mob spawn points within each arena.
Previously all mobs in an arena got the same XZ coordinate (stacked).
This pass assigns each mob a unique position on a circle around the
arena centre so they spawn spread out.

Radius is 8 yalms — enough to separate mobs clearly without pushing
them into walls in the smaller zones (Chamber of Oracles, Throne Room).
"""
import math
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPAWN_FILE = os.path.join(BASE, 'sql', 'mob_spawn_points.sql')

RADIUS = 8.0

# Same block definitions as skcnm_tier2_sql_update.py
TIER2_BLOCKS = {
    'horlais': {
        'range': (17346927, 17347025),
        'stride': 7,
        'arenas': [
            (-395.100, 94.251, -66.500),
            (-155.165, -25.758, 113.470),
            (84.828, -145.775, 293.304),
        ],
    },
    'waughroon': {
        'range': (17367590, 17367693),
        'stride': 7,
        'arenas': [
            (-179.358, 59.695, -142.018),
            (22.500, 0.000, 17.964),
            (222.500, -60.000, 137.946),
        ],
    },
    'balgas': {
        'range': (17375629, 17375727),
        'stride': 7,
        'arenas': [
            (-135.960, 56.144, -222.270),
            (21.231, -4.000, -25.076),
            (181.059, -64.000, 174.999),
        ],
    },
    'sac_gonberry': {
        'range': (17444940, 17445038),
        'stride': 7,
        'arenas': [
            (-280.878, -32.500, 326.971),
            (-1.094, -0.500, 47.607),
            (281.130, 31.500, -273.224),
        ],
    },
    'sac_qull': {
        'range': (17445045, 17445134),
        'stride': 6,
        'arenas': [
            (-280.878, -32.500, 326.971),
            (-1.094, -0.500, 47.607),
            (281.130, 31.500, -273.224),
        ],
    },
    'throne': {
        'range': (17453132, 17453233),
        'stride': 7,
        'arenas': [
            (-464.527, -167.580, -241.576),
            (-784.527, -407.580, -481.576),
            (-1104.527, -647.580, -721.576),
        ],
    },
    'chamber': {
        'range': (17465441, 17465514),
        'stride': 5,
        'arenas': [
            (-2.000, 100.325, -240.000),
            (-2.000, 0.325, 0.000),
            (-2.000, -100.325, 240.000),
        ],
    },
    'qubia_nephiyl': {
        'range': (17621410, 17621480),
        'stride': 5,
        'arenas': [
            (-405.001, -202.125, 400.001),
            (-3.940, -1.625, -0.900),
            (395.000, 199.000, -400.677),
        ],
    },
    'qubia_vaico': {
        'range': (17621485, 17621555),
        'stride': 5,
        'arenas': [
            (-405.001, -202.125, 400.001),
            (-3.940, -1.625, -0.900),
            (395.000, 199.000, -400.677),
        ],
    },
}

def get_spread(mob_id, block):
    """
    Returns (cx, cy, cz, x_spread, z_spread) for this mob.
    cx/cy/cz = arena centre.  x_spread/z_spread = per-mob offset.
    """
    first  = block['range'][0]
    stride = block['stride']
    offset = mob_id - first
    set_num        = offset // stride
    pos_in_stride  = offset % stride

    arena = block['arenas'][set_num % 3]
    cx, cy, cz = arena

    # Spread N mobs evenly around a circle where N = stride - 1 (one gap slot)
    n_mobs = stride - 1
    angle  = (2.0 * math.pi * pos_in_stride) / n_mobs
    x_off  = RADIUS * math.cos(angle)
    z_off  = RADIUS * math.sin(angle)

    return cx, cy, cz, x_off, z_off


VALS_PREFIX = "INSERT INTO `mob_spawn_points` VALUES ("

def fmt(v):
    if v == int(v):
        return f"{int(v)}.000"
    return f"{v:.3f}"

def parse_spawn_line(line):
    s = line.rstrip()
    if not s.startswith(VALS_PREFIX):
        return None
    inner = s[len(VALS_PREFIX):-2]
    parts = []
    buf = ''
    in_quote = False
    escape_next = False
    for ch in inner:
        if escape_next:
            buf += ch; escape_next = False
        elif ch == '\\':
            buf += ch; escape_next = True
        elif ch == "'" and not in_quote:
            in_quote = True; buf += ch
        elif ch == "'" and in_quote:
            in_quote = False; buf += ch
        elif ch == ',' and not in_quote:
            parts.append(buf); buf = ''
        else:
            buf += ch
    if buf:
        parts.append(buf)
    if len(parts) < 11:
        return None
    try:
        mob_id = int(parts[0])
        pos_x  = float(parts[7])
        pos_y  = float(parts[8])
        pos_z  = float(parts[9])
        return mob_id, pos_x, pos_y, pos_z, parts
    except (ValueError, IndexError):
        return None


def run():
    with open(SPAWN_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    changed = 0
    out = []
    for line in lines:
        parsed = parse_spawn_line(line)
        if parsed is None:
            out.append(line)
            continue

        mob_id, pos_x, pos_y, pos_z, parts = parsed
        matched = False

        for block in TIER2_BLOCKS.values():
            lo, hi = block['range']
            if lo <= mob_id <= hi:
                matched = True
                cx, cy, cz, x_off, z_off = get_spread(mob_id, block)
                new_x = cx + x_off
                new_z = cz + z_off
                # Only rewrite if stacked (all at same centre) or if already
                # at the arena centre (within 0.1 tolerance)
                at_centre = (abs(pos_x - cx) < 0.1 and abs(pos_z - cz) < 0.1)
                if at_centre:
                    parts[7]  = fmt(new_x)
                    # Y stays unchanged (floor height)
                    parts[9]  = fmt(new_z)
                    changed += 1
                    out.append(f"INSERT INTO `mob_spawn_points` VALUES ({','.join(parts)});\n")
                else:
                    # Already has a hand-crafted position — leave it alone
                    out.append(line)
                break

        if not matched:
            out.append(line)

    with open(SPAWN_FILE, 'w', encoding='utf-8') as f:
        f.writelines(out)

    print(f"mob_spawn_points.sql: {changed} rows spread")


if __name__ == '__main__':
    run()
