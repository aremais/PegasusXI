-- GM Weapon 005: GM Scythe
-- Base item: 21821 Lost Sickle +1
-- Purpose: Rare/Ex-style special-appearance GM Scythe weapon.
-- Appearance:
--   Uses Lost Sickle +1 model MId 795.
--
-- Notes:
--   Server-side name is changed to gm_scythe.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.
--   Search did not find a specific lost_sickle additional-effect script/DB row.
--   This patch does not implement the Additional effect: Death behavior.

SET @itemid := 21821;

UPDATE item_basic
SET
    name = 'gm_scythe',
    sortname = 'gm_scythe',
    name_jp = 'GM Scythe',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_scythe',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 795,
    slot = 1,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_scythe',
    skill = 7,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 513,
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
    (@itemid, 25, 1), -- ACC +1
    (@itemid, 30, 1); -- MACC +1

-- Final Lv.99 totals:
-- Effective DMG 545 = base 8 + hidden DMG_RATING 537
-- HP+220, MP+80
-- STR+70, DEX+20, INT+35, VIT+45
-- Attack+242 including base ATT+2
-- Accuracy+156 including base ACC+1
-- Magic Accuracy+81 including base MACC+1
-- Store TP+35
-- Damage Taken -6%
-- Double Attack+5
-- Haste Gear +1.5%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 42, 51, 10),
    (@itemid, 2, 11, 51, 10),
    (@itemid, 5, 4, 51, 10),
    (@itemid, 8, 4, 51, 10),
    (@itemid, 9, 1, 51, 10),
    (@itemid, 10, 2, 51, 10),
    (@itemid, 12, 2, 51, 10),
    (@itemid, 23, 12, 51, 10),
    (@itemid, 25, 8, 51, 10),
    (@itemid, 30, 4, 51, 10),
    (@itemid, 73, 2, 51, 10),
    (@itemid, 160, -30, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 8, 51, 10),

    -- Lv.20
    (@itemid, 287, 55, 51, 20),
    (@itemid, 2, 11, 51, 20),
    (@itemid, 5, 4, 51, 20),
    (@itemid, 8, 5, 51, 20),
    (@itemid, 9, 1, 51, 20),
    (@itemid, 10, 3, 51, 20),
    (@itemid, 12, 3, 51, 20),
    (@itemid, 23, 12, 51, 20),
    (@itemid, 25, 8, 51, 20),
    (@itemid, 30, 4, 51, 20),
    (@itemid, 73, 3, 51, 20),
    (@itemid, 160, -30, 51, 20),
    (@itemid, 384, 8, 51, 20),

    -- Lv.30
    (@itemid, 287, 55, 51, 30),
    (@itemid, 2, 18, 51, 30),
    (@itemid, 5, 6, 51, 30),
    (@itemid, 8, 7, 51, 30),
    (@itemid, 9, 2, 51, 30),
    (@itemid, 10, 4, 51, 30),
    (@itemid, 12, 5, 51, 30),
    (@itemid, 23, 18, 51, 30),
    (@itemid, 25, 13, 51, 30),
    (@itemid, 30, 8, 51, 30),
    (@itemid, 73, 3, 51, 30),
    (@itemid, 160, -48, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 12, 51, 30),

    -- Lv.40
    (@itemid, 287, 60, 51, 40),
    (@itemid, 2, 22, 51, 40),
    (@itemid, 5, 8, 51, 40),
    (@itemid, 8, 8, 51, 40),
    (@itemid, 9, 2, 51, 40),
    (@itemid, 10, 5, 51, 40),
    (@itemid, 12, 6, 51, 40),
    (@itemid, 23, 22, 51, 40),
    (@itemid, 25, 15, 51, 40),
    (@itemid, 30, 10, 51, 40),
    (@itemid, 73, 4, 51, 40),
    (@itemid, 160, -60, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 15, 51, 40),

    -- Lv.50
    (@itemid, 287, 60, 51, 50),
    (@itemid, 2, 26, 51, 50),
    (@itemid, 5, 10, 51, 50),
    (@itemid, 8, 9, 51, 50),
    (@itemid, 9, 3, 51, 50),
    (@itemid, 10, 6, 51, 50),
    (@itemid, 12, 7, 51, 50),
    (@itemid, 23, 26, 51, 50),
    (@itemid, 25, 18, 51, 50),
    (@itemid, 30, 12, 51, 50),
    (@itemid, 73, 4, 51, 50),
    (@itemid, 160, -72, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 18, 51, 50),

    -- Lv.60
    (@itemid, 287, 60, 51, 60),
    (@itemid, 2, 30, 51, 60),
    (@itemid, 5, 12, 51, 60),
    (@itemid, 8, 10, 51, 60),
    (@itemid, 9, 3, 51, 60),
    (@itemid, 10, 7, 51, 60),
    (@itemid, 12, 8, 51, 60),
    (@itemid, 23, 30, 51, 60),
    (@itemid, 25, 20, 51, 60),
    (@itemid, 30, 14, 51, 60),
    (@itemid, 73, 5, 51, 60),
    (@itemid, 160, -78, 51, 60),
    (@itemid, 384, 20, 51, 60),

    -- Lv.70
    (@itemid, 287, 60, 51, 70),
    (@itemid, 2, 32, 51, 70),
    (@itemid, 5, 12, 51, 70),
    (@itemid, 8, 10, 51, 70),
    (@itemid, 9, 3, 51, 70),
    (@itemid, 10, 7, 51, 70),
    (@itemid, 12, 8, 51, 70),
    (@itemid, 23, 32, 51, 70),
    (@itemid, 25, 21, 51, 70),
    (@itemid, 30, 14, 51, 70),
    (@itemid, 73, 5, 51, 70),
    (@itemid, 160, -84, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 21, 51, 70),

    -- Lv.80
    (@itemid, 287, 55, 51, 80),
    (@itemid, 2, 28, 51, 80),
    (@itemid, 5, 10, 51, 80),
    (@itemid, 8, 8, 51, 80),
    (@itemid, 9, 2, 51, 80),
    (@itemid, 10, 5, 51, 80),
    (@itemid, 12, 6, 51, 80),
    (@itemid, 23, 28, 51, 80),
    (@itemid, 25, 19, 51, 80),
    (@itemid, 30, 10, 51, 80),
    (@itemid, 73, 4, 51, 80),
    (@itemid, 160, -78, 51, 80),
    (@itemid, 384, 20, 51, 80),

    -- Lv.90
    (@itemid, 287, 50, 51, 90),
    (@itemid, 2, 24, 51, 90),
    (@itemid, 5, 8, 51, 90),
    (@itemid, 8, 6, 51, 90),
    (@itemid, 9, 2, 51, 90),
    (@itemid, 10, 4, 51, 90),
    (@itemid, 12, 5, 51, 90),
    (@itemid, 23, 24, 51, 90),
    (@itemid, 25, 17, 51, 90),
    (@itemid, 30, 8, 51, 90),
    (@itemid, 73, 3, 51, 90),
    (@itemid, 160, -72, 51, 90),
    (@itemid, 384, 18, 51, 90),

    -- Lv.99
    (@itemid, 287, 40, 51, 99),
    (@itemid, 2, 18, 51, 99),
    (@itemid, 5, 6, 51, 99),
    (@itemid, 8, 7, 51, 99),
    (@itemid, 9, 1, 51, 99),
    (@itemid, 10, 2, 51, 99),
    (@itemid, 12, 3, 51, 99),
    (@itemid, 23, 18, 51, 99),
    (@itemid, 25, 16, 51, 99),
    (@itemid, 30, 6, 51, 99),
    (@itemid, 73, 2, 51, 99),
    (@itemid, 160, -48, 51, 99),
    (@itemid, 384, 10, 51, 99);
