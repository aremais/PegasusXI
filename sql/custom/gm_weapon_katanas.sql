-- GM Weapon 007A: GM Katana Power
-- Base item: 16911 Amanojaku
-- Focus: stronger per-hit katana, STR/Attack/Double Attack.
--
-- GM Weapon 007B: GM Katana Speed
-- Base item: 16912 Kitsutsuki
-- Focus: faster evasive katana, DEX/AGI/Accuracy/Evasion/Haste.
--
-- Notes:
--   Both are Level 1 + All Jobs.
--   Both keep original Rare/Ex-style flags.
--   Both use slot 3 so they can be used for dual-wield behavior.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

-- ------------------------------------------------------------
-- 16911 Amanojaku -> GM Katana Power
-- ------------------------------------------------------------

SET @power := 16911;

UPDATE item_basic
SET
    name = 'gm_katana_power',
    sortname = 'gm_katana_power',
    name_jp = 'GM Katana Power',
    aH = 0,
    BaseSell = 0
WHERE itemid = @power;

UPDATE item_equipment
SET
    name = 'gm_katana_power',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 310,
    slot = 3,
    su_level = 0
WHERE itemId = @power;

UPDATE item_weapon
SET
    name = 'gm_katana_power',
    skill = 9,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 221,
    dmg = 5,
    unlock_points = 0
WHERE itemId = @power;

DELETE FROM item_mods
WHERE itemId = @power;

DELETE FROM item_latents
WHERE itemId = @power;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@power, 23, 1), -- ATT +1
    (@power, 25, 1); -- ACC +1

-- Final Lv.99 totals:
-- Effective DMG 330 = base 5 + hidden DMG_RATING 325
-- HP+150
-- STR+50, DEX+35, VIT+25
-- Attack+176 including base ATT+1
-- Accuracy+161 including base ACC+1
-- Store TP+25
-- Damage Taken -4%
-- Double Attack+9
-- Haste Gear +2.5%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@power, 287, 27, 51, 10),
    (@power, 2, 8, 51, 10),
    (@power, 8, 3, 51, 10),
    (@power, 9, 2, 51, 10),
    (@power, 10, 2, 51, 10),
    (@power, 23, 8, 51, 10),
    (@power, 25, 8, 51, 10),
    (@power, 73, 1, 51, 10),
    (@power, 160, -20, 51, 10),
    (@power, 288, 1, 51, 10),
    (@power, 384, 10, 51, 10),

    -- Lv.20
    (@power, 287, 33, 51, 20),
    (@power, 2, 8, 51, 20),
    (@power, 8, 4, 51, 20),
    (@power, 9, 3, 51, 20),
    (@power, 10, 2, 51, 20),
    (@power, 23, 10, 51, 20),
    (@power, 25, 9, 51, 20),
    (@power, 73, 2, 51, 20),
    (@power, 160, -20, 51, 20),
    (@power, 384, 10, 51, 20),

    -- Lv.30
    (@power, 287, 35, 51, 30),
    (@power, 2, 12, 51, 30),
    (@power, 8, 5, 51, 30),
    (@power, 9, 4, 51, 30),
    (@power, 10, 3, 51, 30),
    (@power, 23, 15, 51, 30),
    (@power, 25, 12, 51, 30),
    (@power, 73, 2, 51, 30),
    (@power, 160, -30, 51, 30),
    (@power, 288, 1, 51, 30),
    (@power, 384, 20, 51, 30),

    -- Lv.40
    (@power, 287, 35, 51, 40),
    (@power, 2, 15, 51, 40),
    (@power, 8, 6, 51, 40),
    (@power, 9, 4, 51, 40),
    (@power, 10, 3, 51, 40),
    (@power, 23, 18, 51, 40),
    (@power, 25, 15, 51, 40),
    (@power, 73, 3, 51, 40),
    (@power, 160, -40, 51, 40),
    (@power, 288, 1, 51, 40),
    (@power, 384, 25, 51, 40),

    -- Lv.50
    (@power, 287, 35, 51, 50),
    (@power, 2, 18, 51, 50),
    (@power, 8, 7, 51, 50),
    (@power, 9, 5, 51, 50),
    (@power, 10, 4, 51, 50),
    (@power, 23, 22, 51, 50),
    (@power, 25, 18, 51, 50),
    (@power, 73, 3, 51, 50),
    (@power, 160, -50, 51, 50),
    (@power, 288, 1, 51, 50),
    (@power, 384, 30, 51, 50),

    -- Lv.60
    (@power, 287, 35, 51, 60),
    (@power, 2, 22, 51, 60),
    (@power, 8, 7, 51, 60),
    (@power, 9, 5, 51, 60),
    (@power, 10, 4, 51, 60),
    (@power, 23, 25, 51, 60),
    (@power, 25, 20, 51, 60),
    (@power, 73, 4, 51, 60),
    (@power, 160, -55, 51, 60),
    (@power, 288, 1, 51, 60),
    (@power, 384, 35, 51, 60),

    -- Lv.70
    (@power, 287, 35, 51, 70),
    (@power, 2, 24, 51, 70),
    (@power, 8, 7, 51, 70),
    (@power, 9, 5, 51, 70),
    (@power, 10, 3, 51, 70),
    (@power, 23, 25, 51, 70),
    (@power, 25, 20, 51, 70),
    (@power, 73, 4, 51, 70),
    (@power, 160, -60, 51, 70),
    (@power, 288, 1, 51, 70),
    (@power, 384, 35, 51, 70),

    -- Lv.80
    (@power, 287, 35, 51, 80),
    (@power, 2, 20, 51, 80),
    (@power, 8, 5, 51, 80),
    (@power, 9, 3, 51, 80),
    (@power, 10, 2, 51, 80),
    (@power, 23, 22, 51, 80),
    (@power, 25, 18, 51, 80),
    (@power, 73, 3, 51, 80),
    (@power, 160, -50, 51, 80),
    (@power, 288, 1, 51, 80),
    (@power, 384, 30, 51, 80),

    -- Lv.90
    (@power, 287, 30, 51, 90),
    (@power, 2, 15, 51, 90),
    (@power, 8, 4, 51, 90),
    (@power, 9, 3, 51, 90),
    (@power, 10, 1, 51, 90),
    (@power, 23, 20, 51, 90),
    (@power, 25, 15, 51, 90),
    (@power, 73, 2, 51, 90),
    (@power, 160, -45, 51, 90),
    (@power, 288, 1, 51, 90),
    (@power, 384, 30, 51, 90),

    -- Lv.99
    (@power, 287, 25, 51, 99),
    (@power, 2, 8, 51, 99),
    (@power, 8, 2, 51, 99),
    (@power, 9, 1, 51, 99),
    (@power, 10, 1, 51, 99),
    (@power, 23, 10, 51, 99),
    (@power, 25, 25, 51, 99),
    (@power, 73, 1, 51, 99),
    (@power, 160, -30, 51, 99),
    (@power, 288, 1, 51, 99),
    (@power, 384, 25, 51, 99);

-- ------------------------------------------------------------
-- 16912 Kitsutsuki -> GM Katana Speed
-- ------------------------------------------------------------

SET @speed := 16912;

UPDATE item_basic
SET
    name = 'gm_katana_speed',
    sortname = 'gm_katana_speed',
    name_jp = 'GM Katana Speed',
    aH = 0,
    BaseSell = 0
WHERE itemid = @speed;

UPDATE item_equipment
SET
    name = 'gm_katana_speed',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 315,
    slot = 3,
    su_level = 0
WHERE itemId = @speed;

UPDATE item_weapon
SET
    name = 'gm_katana_speed',
    skill = 9,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 2,
    hit = 1,
    delay = 185,
    dmg = 4,
    unlock_points = 0
WHERE itemId = @speed;

DELETE FROM item_mods
WHERE itemId = @speed;

DELETE FROM item_latents
WHERE itemId = @speed;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@speed, 25, 2), -- ACC +2
    (@speed, 68, 2); -- EVA +2

-- Final Lv.99 totals:
-- Effective DMG 285 = base 4 + hidden DMG_RATING 281
-- HP+110
-- STR+25, DEX+60, AGI+55
-- Attack+125
-- Accuracy+202 including base ACC+2
-- Evasion+112 including base EVA+2
-- Store TP+25
-- Damage Taken -3.5%
-- Double Attack+12
-- Haste Gear +4%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@speed, 287, 21, 51, 10),
    (@speed, 2, 5, 51, 10),
    (@speed, 8, 1, 51, 10),
    (@speed, 9, 4, 51, 10),
    (@speed, 11, 4, 51, 10),
    (@speed, 23, 6, 51, 10),
    (@speed, 25, 10, 51, 10),
    (@speed, 68, 5, 51, 10),
    (@speed, 73, 1, 51, 10),
    (@speed, 160, -15, 51, 10),
    (@speed, 288, 1, 51, 10),
    (@speed, 384, 20, 51, 10),

    -- Lv.20
    (@speed, 287, 30, 51, 20),
    (@speed, 2, 5, 51, 20),
    (@speed, 8, 2, 51, 20),
    (@speed, 9, 5, 51, 20),
    (@speed, 11, 5, 51, 20),
    (@speed, 23, 7, 51, 20),
    (@speed, 25, 12, 51, 20),
    (@speed, 68, 6, 51, 20),
    (@speed, 73, 2, 51, 20),
    (@speed, 160, -15, 51, 20),
    (@speed, 288, 1, 51, 20),
    (@speed, 384, 20, 51, 20),

    -- Lv.30
    (@speed, 287, 30, 51, 30),
    (@speed, 2, 8, 51, 30),
    (@speed, 8, 2, 51, 30),
    (@speed, 9, 6, 51, 30),
    (@speed, 11, 6, 51, 30),
    (@speed, 23, 10, 51, 30),
    (@speed, 25, 16, 51, 30),
    (@speed, 68, 8, 51, 30),
    (@speed, 73, 2, 51, 30),
    (@speed, 160, -25, 51, 30),
    (@speed, 288, 1, 51, 30),
    (@speed, 384, 30, 51, 30),

    -- Lv.40
    (@speed, 287, 35, 51, 40),
    (@speed, 2, 10, 51, 40),
    (@speed, 8, 3, 51, 40),
    (@speed, 9, 7, 51, 40),
    (@speed, 11, 6, 51, 40),
    (@speed, 23, 12, 51, 40),
    (@speed, 25, 20, 51, 40),
    (@speed, 68, 10, 51, 40),
    (@speed, 73, 3, 51, 40),
    (@speed, 160, -30, 51, 40),
    (@speed, 288, 1, 51, 40),
    (@speed, 384, 35, 51, 40),

    -- Lv.50
    (@speed, 287, 35, 51, 50),
    (@speed, 2, 12, 51, 50),
    (@speed, 8, 3, 51, 50),
    (@speed, 9, 8, 51, 50),
    (@speed, 11, 7, 51, 50),
    (@speed, 23, 15, 51, 50),
    (@speed, 25, 24, 51, 50),
    (@speed, 68, 12, 51, 50),
    (@speed, 73, 3, 51, 50),
    (@speed, 160, -35, 51, 50),
    (@speed, 288, 1, 51, 50),
    (@speed, 384, 45, 51, 50),

    -- Lv.60
    (@speed, 287, 35, 51, 60),
    (@speed, 2, 15, 51, 60),
    (@speed, 8, 4, 51, 60),
    (@speed, 9, 8, 51, 60),
    (@speed, 11, 7, 51, 60),
    (@speed, 23, 16, 51, 60),
    (@speed, 25, 26, 51, 60),
    (@speed, 68, 14, 51, 60),
    (@speed, 73, 4, 51, 60),
    (@speed, 160, -40, 51, 60),
    (@speed, 288, 2, 51, 60),
    (@speed, 384, 50, 51, 60),

    -- Lv.70
    (@speed, 287, 30, 51, 70),
    (@speed, 2, 16, 51, 70),
    (@speed, 8, 4, 51, 70),
    (@speed, 9, 8, 51, 70),
    (@speed, 11, 7, 51, 70),
    (@speed, 23, 16, 51, 70),
    (@speed, 25, 26, 51, 70),
    (@speed, 68, 14, 51, 70),
    (@speed, 73, 4, 51, 70),
    (@speed, 160, -45, 51, 70),
    (@speed, 288, 2, 51, 70),
    (@speed, 384, 55, 51, 70),

    -- Lv.80
    (@speed, 287, 25, 51, 80),
    (@speed, 2, 14, 51, 80),
    (@speed, 8, 3, 51, 80),
    (@speed, 9, 6, 51, 80),
    (@speed, 11, 5, 51, 80),
    (@speed, 23, 15, 51, 80),
    (@speed, 25, 24, 51, 80),
    (@speed, 68, 14, 51, 80),
    (@speed, 73, 3, 51, 80),
    (@speed, 160, -45, 51, 80),
    (@speed, 288, 1, 51, 80),
    (@speed, 384, 55, 51, 80),

    -- Lv.90
    (@speed, 287, 20, 51, 90),
    (@speed, 2, 15, 51, 90),
    (@speed, 8, 2, 51, 90),
    (@speed, 9, 5, 51, 90),
    (@speed, 11, 5, 51, 90),
    (@speed, 23, 15, 51, 90),
    (@speed, 25, 22, 51, 90),
    (@speed, 68, 14, 51, 90),
    (@speed, 73, 2, 51, 90),
    (@speed, 160, -50, 51, 90),
    (@speed, 288, 1, 51, 90),
    (@speed, 384, 45, 51, 90),

    -- Lv.99
    (@speed, 287, 20, 51, 99),
    (@speed, 2, 10, 51, 99),
    (@speed, 8, 1, 51, 99),
    (@speed, 9, 3, 51, 99),
    (@speed, 11, 3, 51, 99),
    (@speed, 23, 13, 51, 99),
    (@speed, 25, 20, 51, 99),
    (@speed, 68, 13, 51, 99),
    (@speed, 73, 1, 51, 99),
    (@speed, 160, -50, 51, 99),
    (@speed, 288, 1, 51, 99),
    (@speed, 384, 45, 51, 99);
