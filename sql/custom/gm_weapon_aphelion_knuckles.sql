-- GM Weapon 001: GM Knuckles
-- Base item: 20514 Aphelion Knuckles
-- Purpose: Rare/Ex special-appearance GM Hand-to-Hand weapon.
-- Appearance:
--   Uses Aphelion Knuckles model MId 483.
--   Lightsaber-style blade appears when drawn.
--
-- Notes:
--   Server-side name is changed to gm_knuckles.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 20514;

UPDATE item_basic
SET
    name = 'gm_knuckles',
    sortname = 'gm_knuckles',
    name_jp = 'GM Knuckles',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_knuckles',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 483,
    slot = 1,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_knuckles',
    skill = 1,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 4,
    hit = 1,
    delay = 540,
    dmg = 4,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter stat.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 25, 1); -- ACC +1

-- Final Lv.99 totals:
-- Effective DMG 300 = base 4 + hidden DMG_RATING 296
-- HP+150
-- STR+35, DEX+35, VIT+20
-- ATT+150, ACC+151 including base ACC+1
-- Store TP+25
-- Damage Taken -5%
-- Double Attack+10
-- Haste Gear +3%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 21, 51, 10),
    (@itemid, 2, 8, 51, 10),
    (@itemid, 8, 2, 51, 10),
    (@itemid, 9, 2, 51, 10),
    (@itemid, 10, 1, 51, 10),
    (@itemid, 23, 8, 51, 10),
    (@itemid, 25, 7, 51, 10),
    (@itemid, 73, 1, 51, 10),
    (@itemid, 160, -25, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 15, 51, 10),

    -- Lv.20
    (@itemid, 287, 30, 51, 20),
    (@itemid, 2, 7, 51, 20),
    (@itemid, 8, 2, 51, 20),
    (@itemid, 9, 2, 51, 20),
    (@itemid, 10, 1, 51, 20),
    (@itemid, 23, 7, 51, 20),
    (@itemid, 25, 7, 51, 20),
    (@itemid, 73, 2, 51, 20),
    (@itemid, 160, -25, 51, 20),
    (@itemid, 384, 15, 51, 20),

    -- Lv.30
    (@itemid, 287, 30, 51, 30),
    (@itemid, 2, 12, 51, 30),
    (@itemid, 8, 3, 51, 30),
    (@itemid, 9, 3, 51, 30),
    (@itemid, 10, 2, 51, 30),
    (@itemid, 23, 12, 51, 30),
    (@itemid, 25, 12, 51, 30),
    (@itemid, 73, 2, 51, 30),
    (@itemid, 160, -40, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 24, 51, 30),

    -- Lv.40
    (@itemid, 287, 35, 51, 40),
    (@itemid, 2, 15, 51, 40),
    (@itemid, 8, 4, 51, 40),
    (@itemid, 9, 4, 51, 40),
    (@itemid, 10, 2, 51, 40),
    (@itemid, 23, 15, 51, 40),
    (@itemid, 25, 15, 51, 40),
    (@itemid, 73, 3, 51, 40),
    (@itemid, 160, -50, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 30, 51, 40),

    -- Lv.50
    (@itemid, 287, 35, 51, 50),
    (@itemid, 2, 18, 51, 50),
    (@itemid, 8, 5, 51, 50),
    (@itemid, 9, 5, 51, 50),
    (@itemid, 10, 3, 51, 50),
    (@itemid, 23, 18, 51, 50),
    (@itemid, 25, 18, 51, 50),
    (@itemid, 73, 3, 51, 50),
    (@itemid, 160, -60, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 36, 51, 50),

    -- Lv.60
    (@itemid, 287, 35, 51, 60),
    (@itemid, 2, 20, 51, 60),
    (@itemid, 8, 5, 51, 60),
    (@itemid, 9, 5, 51, 60),
    (@itemid, 10, 3, 51, 60),
    (@itemid, 23, 20, 51, 60),
    (@itemid, 25, 20, 51, 60),
    (@itemid, 73, 3, 51, 60),
    (@itemid, 160, -65, 51, 60),
    (@itemid, 288, 1, 51, 60),
    (@itemid, 384, 39, 51, 60),

    -- Lv.70
    (@itemid, 287, 35, 51, 70),
    (@itemid, 2, 22, 51, 70),
    (@itemid, 8, 5, 51, 70),
    (@itemid, 9, 5, 51, 70),
    (@itemid, 10, 3, 51, 70),
    (@itemid, 23, 22, 51, 70),
    (@itemid, 25, 22, 51, 70),
    (@itemid, 73, 4, 51, 70),
    (@itemid, 160, -70, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 42, 51, 70),

    -- Lv.80
    (@itemid, 287, 30, 51, 80),
    (@itemid, 2, 20, 51, 80),
    (@itemid, 8, 4, 51, 80),
    (@itemid, 9, 4, 51, 80),
    (@itemid, 10, 2, 51, 80),
    (@itemid, 23, 20, 51, 80),
    (@itemid, 25, 20, 51, 80),
    (@itemid, 73, 3, 51, 80),
    (@itemid, 160, -65, 51, 80),
    (@itemid, 288, 1, 51, 80),
    (@itemid, 384, 39, 51, 80),

    -- Lv.90
    (@itemid, 287, 30, 51, 90),
    (@itemid, 2, 18, 51, 90),
    (@itemid, 8, 4, 51, 90),
    (@itemid, 9, 4, 51, 90),
    (@itemid, 10, 2, 51, 90),
    (@itemid, 23, 18, 51, 90),
    (@itemid, 25, 18, 51, 90),
    (@itemid, 73, 3, 51, 90),
    (@itemid, 160, -60, 51, 90),
    (@itemid, 288, 1, 51, 90),
    (@itemid, 384, 36, 51, 90),

    -- Lv.99
    (@itemid, 287, 15, 51, 99),
    (@itemid, 2, 10, 51, 99),
    (@itemid, 8, 6, 51, 99),
    (@itemid, 9, 6, 51, 99),
    (@itemid, 10, 1, 51, 99),
    (@itemid, 23, 10, 51, 99),
    (@itemid, 25, 10, 51, 99),
    (@itemid, 73, 1, 51, 99),
    (@itemid, 160, -40, 51, 99),
    (@itemid, 288, 2, 51, 99),
    (@itemid, 384, 24, 51, 99);
