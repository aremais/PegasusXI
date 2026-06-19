-- GM Weapon 009: GM Staff
-- Base item: 22070 Ranine Staff
-- Purpose: Rare/Ex all-purpose mage/support GM Staff.
-- Focus:
--   MP, INT, MND, CHR, Magic Attack, Magic Accuracy,
--   Magic Evasion, Fast Cast, Refresh, Regen, DT-.
--
-- Notes:
--   Server-side name is changed to gm_staff.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 22070;

UPDATE item_basic
SET
    name = 'gm_staff',
    sortname = 'gm_staff',
    name_jp = 'GM Staff',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_staff',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 861,
    slot = 1,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_staff',
    skill = 12,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 3,
    hit = 1,
    delay = 366,
    dmg = 4,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter mage/support stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 5, 10),  -- MP +10
    (@itemid, 12, 1),  -- INT +1
    (@itemid, 13, 1),  -- MND +1
    (@itemid, 28, 1),  -- MATT +1
    (@itemid, 30, 2);  -- MACC +2

-- Final Lv.99 totals:
-- Effective DMG 260 = base 4 + hidden DMG_RATING 256
-- HP+120, MP+350
-- STR+15, DEX+15
-- INT+66 including base INT+1
-- MND+66 including base MND+1
-- CHR+35
-- Attack+60
-- Accuracy+100
-- Magic Attack+211 including base MATT+1
-- Magic Accuracy+262 including base MACC+2
-- Magic Evasion+180
-- Store TP+10
-- Damage Taken -5%
-- Fast Cast+15
-- Refresh+6
-- Regen+4
-- Haste Gear +1%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 21, 51, 10),
    (@itemid, 2, 5, 51, 10),
    (@itemid, 5, 25, 51, 10),
    (@itemid, 8, 1, 51, 10),
    (@itemid, 9, 1, 51, 10),
    (@itemid, 12, 4, 51, 10),
    (@itemid, 13, 4, 51, 10),
    (@itemid, 14, 2, 51, 10),
    (@itemid, 23, 3, 51, 10),
    (@itemid, 25, 5, 51, 10),
    (@itemid, 28, 10, 51, 10),
    (@itemid, 30, 12, 51, 10),
    (@itemid, 31, 8, 51, 10),
    (@itemid, 73, 1, 51, 10),
    (@itemid, 160, -25, 51, 10),
    (@itemid, 170, 1, 51, 10),
    (@itemid, 369, 1, 51, 10),
    (@itemid, 370, 1, 51, 10),
    (@itemid, 384, 5, 51, 10),

    -- Lv.20
    (@itemid, 287, 25, 51, 20),
    (@itemid, 2, 5, 51, 20),
    (@itemid, 5, 25, 51, 20),
    (@itemid, 8, 1, 51, 20),
    (@itemid, 9, 1, 51, 20),
    (@itemid, 12, 5, 51, 20),
    (@itemid, 13, 5, 51, 20),
    (@itemid, 14, 2, 51, 20),
    (@itemid, 23, 3, 51, 20),
    (@itemid, 25, 5, 51, 20),
    (@itemid, 28, 15, 51, 20),
    (@itemid, 30, 18, 51, 20),
    (@itemid, 31, 12, 51, 20),
    (@itemid, 73, 1, 51, 20),
    (@itemid, 160, -25, 51, 20),
    (@itemid, 170, 1, 51, 20),
    (@itemid, 384, 5, 51, 20),

    -- Lv.30
    (@itemid, 287, 30, 51, 30),
    (@itemid, 2, 10, 51, 30),
    (@itemid, 5, 40, 51, 30),
    (@itemid, 8, 2, 51, 30),
    (@itemid, 9, 2, 51, 30),
    (@itemid, 12, 7, 51, 30),
    (@itemid, 13, 7, 51, 30),
    (@itemid, 14, 4, 51, 30),
    (@itemid, 23, 5, 51, 30),
    (@itemid, 25, 8, 51, 30),
    (@itemid, 28, 22, 51, 30),
    (@itemid, 30, 28, 51, 30),
    (@itemid, 31, 18, 51, 30),
    (@itemid, 73, 1, 51, 30),
    (@itemid, 160, -40, 51, 30),
    (@itemid, 170, 2, 51, 30),
    (@itemid, 369, 1, 51, 30),
    (@itemid, 384, 8, 51, 30),

    -- Lv.40
    (@itemid, 287, 30, 51, 40),
    (@itemid, 2, 12, 51, 40),
    (@itemid, 5, 45, 51, 40),
    (@itemid, 8, 2, 51, 40),
    (@itemid, 9, 2, 51, 40),
    (@itemid, 12, 8, 51, 40),
    (@itemid, 13, 8, 51, 40),
    (@itemid, 14, 4, 51, 40),
    (@itemid, 23, 6, 51, 40),
    (@itemid, 25, 10, 51, 40),
    (@itemid, 28, 28, 51, 40),
    (@itemid, 30, 35, 51, 40),
    (@itemid, 31, 22, 51, 40),
    (@itemid, 73, 1, 51, 40),
    (@itemid, 160, -50, 51, 40),
    (@itemid, 170, 2, 51, 40),
    (@itemid, 370, 1, 51, 40),
    (@itemid, 384, 10, 51, 40),

    -- Lv.50
    (@itemid, 287, 30, 51, 50),
    (@itemid, 2, 15, 51, 50),
    (@itemid, 5, 50, 51, 50),
    (@itemid, 8, 2, 51, 50),
    (@itemid, 9, 2, 51, 50),
    (@itemid, 12, 9, 51, 50),
    (@itemid, 13, 9, 51, 50),
    (@itemid, 14, 5, 51, 50),
    (@itemid, 23, 8, 51, 50),
    (@itemid, 25, 12, 51, 50),
    (@itemid, 28, 35, 51, 50),
    (@itemid, 30, 42, 51, 50),
    (@itemid, 31, 28, 51, 50),
    (@itemid, 73, 1, 51, 50),
    (@itemid, 160, -60, 51, 50),
    (@itemid, 170, 2, 51, 50),
    (@itemid, 369, 1, 51, 50),
    (@itemid, 384, 12, 51, 50),

    -- Lv.60
    (@itemid, 287, 30, 51, 60),
    (@itemid, 2, 18, 51, 60),
    (@itemid, 5, 55, 51, 60),
    (@itemid, 8, 2, 51, 60),
    (@itemid, 9, 2, 51, 60),
    (@itemid, 12, 10, 51, 60),
    (@itemid, 13, 10, 51, 60),
    (@itemid, 14, 5, 51, 60),
    (@itemid, 23, 8, 51, 60),
    (@itemid, 25, 14, 51, 60),
    (@itemid, 28, 40, 51, 60),
    (@itemid, 30, 48, 51, 60),
    (@itemid, 31, 32, 51, 60),
    (@itemid, 73, 1, 51, 60),
    (@itemid, 160, -65, 51, 60),
    (@itemid, 170, 2, 51, 60),
    (@itemid, 369, 1, 51, 60),
    (@itemid, 370, 1, 51, 60),
    (@itemid, 384, 15, 51, 60),

    -- Lv.70
    (@itemid, 287, 30, 51, 70),
    (@itemid, 2, 18, 51, 70),
    (@itemid, 5, 45, 51, 70),
    (@itemid, 8, 2, 51, 70),
    (@itemid, 9, 2, 51, 70),
    (@itemid, 12, 8, 51, 70),
    (@itemid, 13, 8, 51, 70),
    (@itemid, 14, 5, 51, 70),
    (@itemid, 23, 8, 51, 70),
    (@itemid, 25, 14, 51, 70),
    (@itemid, 28, 30, 51, 70),
    (@itemid, 30, 38, 51, 70),
    (@itemid, 31, 25, 51, 70),
    (@itemid, 73, 1, 51, 70),
    (@itemid, 160, -70, 51, 70),
    (@itemid, 170, 2, 51, 70),
    (@itemid, 384, 15, 51, 70),

    -- Lv.80
    (@itemid, 287, 25, 51, 80),
    (@itemid, 2, 15, 51, 80),
    (@itemid, 5, 35, 51, 80),
    (@itemid, 8, 1, 51, 80),
    (@itemid, 9, 1, 51, 80),
    (@itemid, 12, 6, 51, 80),
    (@itemid, 13, 6, 51, 80),
    (@itemid, 14, 4, 51, 80),
    (@itemid, 23, 7, 51, 80),
    (@itemid, 25, 12, 51, 80),
    (@itemid, 28, 18, 51, 80),
    (@itemid, 30, 25, 51, 80),
    (@itemid, 31, 18, 51, 80),
    (@itemid, 73, 1, 51, 80),
    (@itemid, 160, -65, 51, 80),
    (@itemid, 170, 1, 51, 80),
    (@itemid, 370, 1, 51, 80),
    (@itemid, 384, 12, 51, 80),

    -- Lv.90
    (@itemid, 287, 20, 51, 90),
    (@itemid, 2, 12, 51, 90),
    (@itemid, 5, 25, 51, 90),
    (@itemid, 8, 1, 51, 90),
    (@itemid, 9, 1, 51, 90),
    (@itemid, 12, 4, 51, 90),
    (@itemid, 13, 4, 51, 90),
    (@itemid, 14, 3, 51, 90),
    (@itemid, 23, 6, 51, 90),
    (@itemid, 25, 10, 51, 90),
    (@itemid, 28, 8, 51, 90),
    (@itemid, 30, 12, 51, 90),
    (@itemid, 31, 10, 51, 90),
    (@itemid, 73, 1, 51, 90),
    (@itemid, 160, -60, 51, 90),
    (@itemid, 170, 1, 51, 90),
    (@itemid, 384, 8, 51, 90),

    -- Lv.99
    (@itemid, 287, 15, 51, 99),
    (@itemid, 2, 10, 51, 99),
    (@itemid, 5, 40, 51, 99),
    (@itemid, 8, 1, 51, 99),
    (@itemid, 9, 1, 51, 99),
    (@itemid, 12, 4, 51, 99),
    (@itemid, 13, 4, 51, 99),
    (@itemid, 14, 1, 51, 99),
    (@itemid, 23, 6, 51, 99),
    (@itemid, 25, 10, 51, 99),
    (@itemid, 28, 4, 51, 99),
    (@itemid, 30, 8, 51, 99),
    (@itemid, 31, 7, 51, 99),
    (@itemid, 160, -40, 51, 99),
    (@itemid, 170, 1, 51, 99),
    (@itemid, 369, 1, 51, 99),
    (@itemid, 384, 10, 51, 99);
