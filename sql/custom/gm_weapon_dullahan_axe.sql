-- GM Weapon 003: GM Axe
-- Base item: 21745 Dullahan Axe
-- Purpose: Rare/Ex special-appearance GM Axe weapon.
-- Appearance:
--   Uses Dullahan Axe model MId 858.
--
-- Notes:
--   Server-side name is changed to gm_axe.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 21745;

UPDATE item_basic
SET
    name = 'gm_axe',
    sortname = 'gm_axe',
    name_jp = 'GM Axe',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_axe',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 858,
    slot = 3,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_axe',
    skill = 5,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 288,
    dmg = 5,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 23, 1), -- ATT +1
    (@itemid, 25, 1); -- ACC +1

-- Final Lv.99 totals:
-- Effective DMG 360 = base 5 + hidden DMG_RATING 355
-- HP+200
-- STR+55, DEX+25, VIT+40
-- Attack+201 including base ATT+1
-- Accuracy+141 including base ACC+1
-- Store TP+25
-- Damage Taken -6%
-- Double Attack+8
-- Haste Gear +2%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 30, 51, 10),
    (@itemid, 2, 10, 51, 10),
    (@itemid, 8, 3, 51, 10),
    (@itemid, 9, 1, 51, 10),
    (@itemid, 10, 2, 51, 10),
    (@itemid, 23, 10, 51, 10),
    (@itemid, 25, 7, 51, 10),
    (@itemid, 73, 1, 51, 10),
    (@itemid, 160, -30, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 10, 51, 10),

    -- Lv.20
    (@itemid, 287, 35, 51, 20),
    (@itemid, 2, 10, 51, 20),
    (@itemid, 8, 4, 51, 20),
    (@itemid, 9, 2, 51, 20),
    (@itemid, 10, 3, 51, 20),
    (@itemid, 23, 10, 51, 20),
    (@itemid, 25, 7, 51, 20),
    (@itemid, 73, 2, 51, 20),
    (@itemid, 160, -30, 51, 20),
    (@itemid, 384, 10, 51, 20),

    -- Lv.30
    (@itemid, 287, 35, 51, 30),
    (@itemid, 2, 16, 51, 30),
    (@itemid, 8, 6, 51, 30),
    (@itemid, 9, 2, 51, 30),
    (@itemid, 10, 4, 51, 30),
    (@itemid, 23, 16, 51, 30),
    (@itemid, 25, 12, 51, 30),
    (@itemid, 73, 2, 51, 30),
    (@itemid, 160, -48, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 16, 51, 30),

    -- Lv.40
    (@itemid, 287, 40, 51, 40),
    (@itemid, 2, 20, 51, 40),
    (@itemid, 8, 7, 51, 40),
    (@itemid, 9, 3, 51, 40),
    (@itemid, 10, 5, 51, 40),
    (@itemid, 23, 20, 51, 40),
    (@itemid, 25, 14, 51, 40),
    (@itemid, 73, 3, 51, 40),
    (@itemid, 160, -60, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 20, 51, 40),

    -- Lv.50
    (@itemid, 287, 40, 51, 50),
    (@itemid, 2, 24, 51, 50),
    (@itemid, 8, 8, 51, 50),
    (@itemid, 9, 4, 51, 50),
    (@itemid, 10, 6, 51, 50),
    (@itemid, 23, 24, 51, 50),
    (@itemid, 25, 17, 51, 50),
    (@itemid, 73, 3, 51, 50),
    (@itemid, 160, -72, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 24, 51, 50),

    -- Lv.60
    (@itemid, 287, 40, 51, 60),
    (@itemid, 2, 28, 51, 60),
    (@itemid, 8, 8, 51, 60),
    (@itemid, 9, 4, 51, 60),
    (@itemid, 10, 7, 51, 60),
    (@itemid, 23, 28, 51, 60),
    (@itemid, 25, 20, 51, 60),
    (@itemid, 73, 4, 51, 60),
    (@itemid, 160, -78, 51, 60),
    (@itemid, 288, 1, 51, 60),
    (@itemid, 384, 26, 51, 60),

    -- Lv.70
    (@itemid, 287, 40, 51, 70),
    (@itemid, 2, 30, 51, 70),
    (@itemid, 8, 8, 51, 70),
    (@itemid, 9, 4, 51, 70),
    (@itemid, 10, 7, 51, 70),
    (@itemid, 23, 30, 51, 70),
    (@itemid, 25, 21, 51, 70),
    (@itemid, 73, 4, 51, 70),
    (@itemid, 160, -84, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 28, 51, 70),

    -- Lv.80
    (@itemid, 287, 40, 51, 80),
    (@itemid, 2, 26, 51, 80),
    (@itemid, 8, 6, 51, 80),
    (@itemid, 9, 3, 51, 80),
    (@itemid, 10, 5, 51, 80),
    (@itemid, 23, 26, 51, 80),
    (@itemid, 25, 18, 51, 80),
    (@itemid, 73, 3, 51, 80),
    (@itemid, 160, -78, 51, 80),
    (@itemid, 288, 1, 51, 80),
    (@itemid, 384, 26, 51, 80),

    -- Lv.90
    (@itemid, 287, 30, 51, 90),
    (@itemid, 2, 22, 51, 90),
    (@itemid, 8, 5, 51, 90),
    (@itemid, 9, 2, 51, 90),
    (@itemid, 10, 4, 51, 90),
    (@itemid, 23, 22, 51, 90),
    (@itemid, 25, 16, 51, 90),
    (@itemid, 73, 2, 51, 90),
    (@itemid, 160, -72, 51, 90),
    (@itemid, 384, 24, 51, 90),

    -- Lv.99
    (@itemid, 287, 25, 51, 99),
    (@itemid, 2, 14, 51, 99),
    (@itemid, 8, 5, 51, 99),
    (@itemid, 9, 1, 51, 99),
    (@itemid, 10, 2, 51, 99),
    (@itemid, 23, 14, 51, 99),
    (@itemid, 25, 8, 51, 99),
    (@itemid, 73, 1, 51, 99),
    (@itemid, 160, -48, 51, 99),
    (@itemid, 384, 16, 51, 99);
