# Mob aggro audit (bg-wiki aligned)

Aggro behavior comes from **two** database layers. Both must be correct.

## How aggro is resolved in code

1. **`mob_family_system.detects`** — family default (sight, sound, magic, scent, etc.)
2. **`mob_pools.familyid`** — must match `mob_family_system.familyID` (not `mob_resistances.resist_id`)
3. **`mob_pools.true_detection`** — True Sight / True Sound (NM-style); regular mobs should be `0`
4. **Lua** — `mob:setMobMod(xi.mobMod.DETECTION, …)` and mixins (e.g. `scripts/mixins/families/imp_aggro.lua`) override on spawn

Detection is checked in `src/map/ai/controllers/mob_controller.cpp` (`CanDetectTarget` / `CanAggroTarget`).

## What was fixed

### 1. `sql/mob_pools.sql` (pool → family link)

Many pools used **`familyid = resist_id`**. Those ID spaces differ, so mobs inherited the wrong family’s `detects` (e.g. Magic Pot used Bird / sight aggro instead of Magic Pot / magic aggro).

- **2,153** regular pools: `familyid` set from `mob_resistances.name` → matching `mob_family_system.familyID`
- **230** regular pools: `true_detection` cleared (`1` → `0`)

### 2. `sql/mob_family_system.sql` (bg-wiki family defaults)

**123** families updated to match bg-wiki `Detects=` on each [Category:Family](https://www.bg-wiki.com/ffxi/Category:Bestiary) page (MediaWiki API).

Examples:

| Family    | bg-wiki `Detects=` | New `detects` |
|-----------|-------------------|---------------|
| Magic Pot | Magic             | 32 (MAGIC)    |
| Quadav    | sound             | 2 (HEARING)   |
| Orc       | Sight             | 1 (SIGHT)     |
| Bomb      | Sight,Magic       | 33            |
| Flan      | sight, ja         | 129           |

**Not auto-changed:** Avatar pets, Imp (day/night handled in `imp_aggro.lua`), categories with no `Detects=` field or only “True Sight/Sound” in wiki text.

## Verify / re-run audit

```powershell
cd d:\server\tools
pip install -r requirements.txt

# Compare all 208 superfamilies to bg-wiki (writes report, does not edit SQL)
python sync_family_detection_from_wiki.py --delay 1.0

# Apply wiki-parsed fixes to mob_family_system.sql (after reviewing report)
python sync_family_detection_from_wiki.py --delay 1.0 --apply

# Re-check pool familyid vs resist name (already applied to mob_pools.sql)
python fix_mob_aggro_data.py
```

Reports:

- `tools/wiki_family_detection_report.txt` — every mismatch with bg-wiki URL
- `tools/wiki_family_detection.json` — cached wiki parses (resume on re-run)

## Apply to live server

1. Import SQL into MariaDB (`xidb` or your `settings/network.lua` database):
   - `sql/mob_family_system.sql`
   - `sql/mob_pools.sql`
   - Or: `python dbtool.py` → **Update DB** / `python dbtool.py update full`
2. **Restart `xi_map`** so zones reload mob definitions from the DB.
3. Test with **freshly respawned** mobs (old spawns keep in-memory stats until respawn).

## Manual bg-wiki check (single family)

1. Open `https://www.bg-wiki.com/ffxi/Category:<Family_Name>` (spaces, not underscores).
2. In the bestiary box, read **Detects** (icons / text).
3. Compare to `SELECT familyID, family, detects FROM mob_family_system WHERE family = '...'`.
4. Map icons using [Aggressive](https://www.bg-wiki.com/ffxi/Aggressive): Sight=1, Sound=2, Magic=32, Scent=256, Low HP=4, Abilities=64+128.

## Spot-check: Magic Pot

- Family **69** `detects = 32` (magic only) — correct per [Category:Magic Pot](https://www.bg-wiki.com/ffxi/Category:Magic_Pot).
- Pool **2480** `familyid = 69`, `true_detection = 0` — should only aggro when players cast MP spells nearby, not on sneak/invis walk-by.
