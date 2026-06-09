-- GM Weapon 008: GM Great Katana
-- Base item: 21024 Ohakari
-- Purpose: Rare/Ex lightsaber-style GM Great Katana weapon.
-- Appearance:
--   Uses Ohakari model / drawn-blade behavior.
--
-- Notes:
--   Server-side name is changed to gm_great_katana.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 21024;

UPDATE item_basic
SET
    name = 'gm_great_katana',
    sortname = 'gm_great_katana',
    name_jp = 'GM Great Katana',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_great_katana',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 0,
    slot = 1,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_great_katana',
    skill = 10,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 450,
    dmg = 7,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 23, 1), -- ATT +1
    (@itemid, 25, 1), -- ACC +1
    (@itemid, 73, 1); -- Store TP +1

-- Final Lv.99 totals:
-- Effective DMG 500 = base 7 + hidden DMG_RATING 493
-- HP+200
-- STR+60, DEX+45, VIT+30, AGI+20
-- Attack+210 including base ATT+1
-- Accuracy+190 including base ACC+1
-- Store TP+45 including base STP+1
-- Damage Taken -5%
-- Double Attack+6
-- Haste Gear +2%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 41, 51, 10),
    (@itemid, 2, 10, 51, 10),
    (@itemid, 8, 4, 51, 10),
    (@itemid, 9, 2, 51, 10),
    (@itemid, 10, 2, 51, 10),
    (@itemid, 11, 1, 51, 10),
    (@itemid, 23, 10, 51, 10),
    (@itemid, 25, 8, 51, 10),
    (@itemid, 73, 3, 51, 10),
    (@itemid, 160, -25, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 10, 51, 10),

    -- Lv.20
    (@itemid, 287, 47, 51, 20),
    (@itemid, 2, 10, 51, 20),
    (@itemid, 8, 5, 51, 20),
    (@itemid, 9, 3, 51, 20),
    (@itemid, 10, 2, 51, 20),
    (@itemid, 11, 1, 51, 20),
    (@itemid, 23, 10, 51, 20),
    (@itemid, 25, 9, 51, 20),
    (@itemid, 73, 4, 51, 20),
    (@itemid, 160, -25, 51, 20),
    (@itemid, 384, 10, 51, 20),

    -- Lv.30
    (@itemid, 287, 50, 51, 30),
    (@itemid, 2, 16, 51, 30),
    (@itemid, 8, 7, 51, 30),
    (@itemid, 9, 5, 51, 30),
    (@itemid, 10, 3, 51, 30),
    (@itemid, 11, 2, 51, 30),
    (@itemid, 23, 16, 51, 30),
    (@itemid, 25, 14, 51, 30),
    (@itemid, 73, 5, 51, 30),
    (@itemid, 160, -40, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 15, 51, 30),

    -- Lv.40
    (@itemid, 287, 55, 51, 40),
    (@itemid, 2, 20, 51, 40),
    (@itemid, 8, 8, 51, 40),
    (@itemid, 9, 6, 51, 40),
    (@itemid, 10, 4, 51, 40),
    (@itemid, 11, 2, 51, 40),
    (@itemid, 23, 20, 51, 40),
    (@itemid, 25, 18, 51, 40),
    (@itemid, 73, 5, 51, 40),
    (@itemid, 160, -50, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 20, 51, 40),

    -- Lv.50
    (@itemid, 287, 55, 51, 50),
    (@itemid, 2, 24, 51, 50),
    (@itemid, 8, 9, 51, 50),
    (@itemid, 9, 7, 51, 50),
    (@itemid, 10, 4, 51, 50),
    (@itemid, 11, 3, 51, 50),
    (@itemid, 23, 24, 51, 50),
    (@itemid, 25, 22, 51, 50),
    (@itemid, 73, 6, 51, 50),
    (@itemid, 160, -60, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 25, 51, 50),

    -- Lv.60
    (@itemid, 287, 55, 51, 60),
    (@itemid, 2, 28, 51, 60),
    (@itemid, 8, 10, 51, 60),
    (@itemid, 9, 8, 51, 60),
    (@itemid, 10, 5, 51, 60),
    (@itemid, 11, 3, 51, 60),
    (@itemid, 23, 28, 51, 60),
    (@itemid, 25, 25, 51, 60),
    (@itemid, 73, 6, 51, 60),
    (@itemid, 160, -65, 51, 60),
    (@itemid, 384, 30, 51, 60),

    -- Lv.70
    (@itemid, 287, 55, 51, 70),
    (@itemid, 2, 30, 51, 70),
    (@itemid, 8, 10, 51, 70),
    (@itemid, 9, 8, 51, 70),
    (@itemid, 10, 5, 51, 70),
    (@itemid, 11, 3, 51, 70),
    (@itemid, 23, 30, 51, 70),
    (@itemid, 25, 25, 51, 70),
    (@itemid, 73, 6, 51, 70),
    (@itemid, 160, -70, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 30, 51, 70),

    -- Lv.80
    (@itemid, 287, 50, 51, 80),
    (@itemid, 2, 26, 51, 80),
    (@itemid, 8, 7, 51, 80),
    (@itemid, 9, 4, 51, 80),
    (@itemid, 10, 3, 51, 80),
    (@itemid, 11, 2, 51, 80),
    (@itemid, 23, 26, 51, 80),
    (@itemid, 25, 24, 51, 80),
    (@itemid, 73, 5, 51, 80),
    (@itemid, 160, -65, 51, 80),
    (@itemid, 384, 25, 51, 80),

    -- Lv.90
    (@itemid, 287, 45, 51, 90),
    (@itemid, 2, 22, 51, 90),
    (@itemid, 8, 6, 51, 90),
    (@itemid, 9, 2, 51, 90),
    (@itemid, 10, 2, 51, 90),
    (@itemid, 11, 2, 51, 90),
    (@itemid, 23, 25, 51, 90),
    (@itemid, 25, 22, 51, 90),
    (@itemid, 73, 4, 51, 90),
    (@itemid, 160, -55, 51, 90),
    (@itemid, 384, 25, 51, 90),

    -- Lv.99
    (@itemid, 287, 40, 51, 99),
    (@itemid, 2, 14, 51, 99),
    (@itemid, 8, 1, 51, 99),
    (@itemid, 9, 1, 51, 99),
    (@itemid, 10, 2, 51, 99),
    (@itemid, 11, 1, 51, 99),
    (@itemid, 23, 26, 51, 99),
    (@itemid, 25, 32, 51, 99),
    (@itemid, 73, 5, 51, 99),
    (@itemid, 160, -45, 51, 99),
    (@itemid, 288, 1, 51, 99),
    (@itemid, 384, 35, 51, 99);
