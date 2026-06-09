-- GM Weapon 004: GM Great Axe
-- Base item: 21770 Helgoland
-- Purpose: Rare/Ex special-appearance GM Great Axe weapon.
-- Appearance:
--   Uses Helgoland model MId 869.
--
-- Notes:
--   Server-side name is changed to gm_great_axe.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 21770;

UPDATE item_basic
SET
    name = 'gm_great_axe',
    sortname = 'gm_great_axe',
    name_jp = 'GM Great Axe',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_great_axe',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 869,
    slot = 1,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_great_axe',
    skill = 6,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 504,
    dmg = 8,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 23, 2), -- ATT +2
    (@itemid, 25, 1); -- ACC +1

-- Final Lv.99 totals:
-- Effective DMG 550 = base 8 + hidden DMG_RATING 542
-- HP+250
-- STR+75, DEX+20, VIT+55
-- Attack+262 including base ATT+2
-- Accuracy+151 including base ACC+1
-- Store TP+35
-- Damage Taken -7%
-- Double Attack+6
-- Haste Gear +1.5%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 47, 51, 10),
    (@itemid, 2, 12, 51, 10),
    (@itemid, 8, 4, 51, 10),
    (@itemid, 9, 1, 51, 10),
    (@itemid, 10, 3, 51, 10),
    (@itemid, 23, 13, 51, 10),
    (@itemid, 25, 8, 51, 10),
    (@itemid, 73, 2, 51, 10),
    (@itemid, 160, -35, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 8, 51, 10),

    -- Lv.20
    (@itemid, 287, 55, 51, 20),
    (@itemid, 2, 13, 51, 20),
    (@itemid, 8, 5, 51, 20),
    (@itemid, 9, 1, 51, 20),
    (@itemid, 10, 4, 51, 20),
    (@itemid, 23, 13, 51, 20),
    (@itemid, 25, 8, 51, 20),
    (@itemid, 73, 3, 51, 20),
    (@itemid, 160, -35, 51, 20),
    (@itemid, 384, 8, 51, 20),

    -- Lv.30
    (@itemid, 287, 55, 51, 30),
    (@itemid, 2, 20, 51, 30),
    (@itemid, 8, 8, 51, 30),
    (@itemid, 9, 2, 51, 30),
    (@itemid, 10, 6, 51, 30),
    (@itemid, 23, 20, 51, 30),
    (@itemid, 25, 13, 51, 30),
    (@itemid, 73, 3, 51, 30),
    (@itemid, 160, -56, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 12, 51, 30),

    -- Lv.40
    (@itemid, 287, 60, 51, 40),
    (@itemid, 2, 25, 51, 40),
    (@itemid, 8, 9, 51, 40),
    (@itemid, 9, 2, 51, 40),
    (@itemid, 10, 7, 51, 40),
    (@itemid, 23, 25, 51, 40),
    (@itemid, 25, 15, 51, 40),
    (@itemid, 73, 4, 51, 40),
    (@itemid, 160, -70, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 15, 51, 40),

    -- Lv.50
    (@itemid, 287, 60, 51, 50),
    (@itemid, 2, 30, 51, 50),
    (@itemid, 8, 10, 51, 50),
    (@itemid, 9, 3, 51, 50),
    (@itemid, 10, 8, 51, 50),
    (@itemid, 23, 30, 51, 50),
    (@itemid, 25, 18, 51, 50),
    (@itemid, 73, 4, 51, 50),
    (@itemid, 160, -84, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 18, 51, 50),

    -- Lv.60
    (@itemid, 287, 60, 51, 60),
    (@itemid, 2, 35, 51, 60),
    (@itemid, 8, 11, 51, 60),
    (@itemid, 9, 3, 51, 60),
    (@itemid, 10, 9, 51, 60),
    (@itemid, 23, 35, 51, 60),
    (@itemid, 25, 20, 51, 60),
    (@itemid, 73, 5, 51, 60),
    (@itemid, 160, -91, 51, 60),
    (@itemid, 288, 1, 51, 60),
    (@itemid, 384, 20, 51, 60),

    -- Lv.70
    (@itemid, 287, 60, 51, 70),
    (@itemid, 2, 37, 51, 70),
    (@itemid, 8, 11, 51, 70),
    (@itemid, 9, 3, 51, 70),
    (@itemid, 10, 9, 51, 70),
    (@itemid, 23, 37, 51, 70),
    (@itemid, 25, 21, 51, 70),
    (@itemid, 73, 5, 51, 70),
    (@itemid, 160, -98, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 21, 51, 70),

    -- Lv.80
    (@itemid, 287, 55, 51, 80),
    (@itemid, 2, 33, 51, 80),
    (@itemid, 8, 9, 51, 80),
    (@itemid, 9, 2, 51, 80),
    (@itemid, 10, 7, 51, 80),
    (@itemid, 23, 33, 51, 80),
    (@itemid, 25, 19, 51, 80),
    (@itemid, 73, 4, 51, 80),
    (@itemid, 160, -91, 51, 80),
    (@itemid, 384, 20, 51, 80),

    -- Lv.90
    (@itemid, 287, 50, 51, 90),
    (@itemid, 2, 28, 51, 90),
    (@itemid, 8, 8, 51, 90),
    (@itemid, 9, 2, 51, 90),
    (@itemid, 10, 6, 51, 90),
    (@itemid, 23, 28, 51, 90),
    (@itemid, 25, 17, 51, 90),
    (@itemid, 73, 3, 51, 90),
    (@itemid, 160, -84, 51, 90),
    (@itemid, 384, 18, 51, 90),

    -- Lv.99
    (@itemid, 287, 40, 51, 99),
    (@itemid, 2, 17, 51, 99),
    (@itemid, 8, 9, 51, 99),
    (@itemid, 9, 1, 51, 99),
    (@itemid, 10, 6, 51, 99),
    (@itemid, 23, 26, 51, 99),
    (@itemid, 25, 11, 51, 99),
    (@itemid, 73, 2, 51, 99),
    (@itemid, 160, -56, 51, 99),
    (@itemid, 384, 10, 51, 99);
