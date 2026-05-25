"""Column orders for the SQL tables we audit.

Order matches the LandSandBoat ``base`` branch CREATE TABLE definition as of
May 2026. If upstream changes column order, regenerate this file by reading
``CREATE TABLE`` from the relevant upstream SQL.
"""

MOB_POOLS_COLUMNS = [
    "poolid", "name", "packet_name", "speciesid", "modelid",
    "mJob", "sJob", "cmbSkill", "cmbDelay", "cmbDmgMult",
    "behavior", "aggro", "true_detection", "links", "mobType",
    "immunity", "name_prefix", "flag", "entityFlags", "animationsub",
    "hasSpellScript", "spellList", "namevis", "roamflag", "skill_list_id",
    "resist_id", "modelSize", "modelHitboxSize",
]

MOB_SPECIES_SYSTEM_COLUMNS = [
    "speciesID", "species", "familyID", "family", "ecosystemID", "ecosystem",
    "speed", "HP", "MP", "STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR",
    "ATT", "DEF", "ACC", "EVA", "Element", "detects", "charmable",
]

MOB_POOL_MODS_COLUMNS = ["poolid", "modid", "value", "is_mob_mod"]

MOB_DROPLIST_COLUMNS = [
    "dropId", "dropType", "groupId", "groupRate", "itemId", "itemRate",
]

MOB_GROUPS_COLUMNS = [
    "groupid", "poolid", "zoneid", "name", "respawntime", "spawntype",
    "dropid", "HP", "MP", "allegiance", "content_tag",
]

ITEM_BASIC_COLUMNS = [
    "itemid", "subid", "name", "sortname", "type", "stackSize", "flags",
    "aH", "BaseSell",
]


DETECT_FLAGS = {
    0x001: "SIGHT",
    0x002: "HEARING",
    0x004: "LOWHP",
    0x008: "NONE1",
    0x010: "NONE2",
    0x020: "MAGIC",
    0x040: "WEAPONSKILL",
    0x080: "JOBABILITY",
    0x100: "SCENT",
}


def decode_detects(value: int) -> str:
    """Return a human-readable label for a DETECT bitmask, e.g. ``SIGHT|HEARING (0x03)``."""
    if value is None:
        return ""
    try:
        v = int(value)
    except (TypeError, ValueError):
        return str(value)
    if v == 0:
        return "NONE (0x00)"
    names = [name for bit, name in DETECT_FLAGS.items() if v & bit]
    leftover = v & ~sum(DETECT_FLAGS.keys())
    if leftover:
        names.append(f"UNK_0x{leftover:X}")
    return f"{'|'.join(names)} (0x{v:02X})"


MOBMOD_DETECTION = 16
