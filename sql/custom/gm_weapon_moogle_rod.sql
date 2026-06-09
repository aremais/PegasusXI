-- GM Weapon 010: GM Rod
-- Base item: 18401 Moogle Rod
-- Purpose: Rare/Ex healer/support GM Club.
-- Focus:
--   MND, CHR, MP, Magic Accuracy, Magic Evasion,
--   Regen, Refresh, survivability, and light blunt melee.
--
-- Different from GM Staff:
--   GM Staff = stronger caster/nuking/support staff.
--   GM Rod   = stronger healer/party-support/survival club.
--
-- Notes:
--   Server-side name is changed to gm_rod.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs.
--   Keeps original Moogle Rod usable/enchantment row.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 18401;

UPDATE item_basic
SET
    name = 'gm_rod',
    sortname = 'gm_rod',
    name_jp = 'GM Rod',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_rod',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 374,
    slot = 3,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_rod',
    skill = 11,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 3,
    hit = 1,
    delay = 288,
    dmg = 4,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter healer/support stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 5, 10),   -- MP +10
    (@itemid, 13, 2),   -- MND +2
    (@itemid, 14, 1),   -- CHR +1
    (@itemid, 30, 2),   -- MACC +2
    (@itemid, 370, 1);  -- Regen +1

-- Final Lv.99 totals:
-- Effective DMG 250 = base 4 + hidden DMG_RATING 246
-- HP+180, MP+260
-- STR+20, DEX+20
-- MND+75 including base MND+2
-- CHR+55 including base CHR+1
-- Attack+85
-- Accuracy+120
-- Magic Attack+85
-- Magic Accuracy+215 including base MACC+2
-- Magic Evasion+220
-- Store TP+15
-- Damage Taken -6%
-- Fast Cast+8
-- Refresh+4
-- Regen+8 including base Regen+1
-- Haste Gear +1.5%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 18, 51, 10),
    (@itemid, 2, 8, 51, 10),
    (@itemid, 5, 20, 51, 10),
    (@itemid, 8, 1, 51, 10),
    (@itemid, 9, 1, 51, 10),
    (@itemid, 13, 5, 51, 10),
    (@itemid, 14, 3, 51, 10),
    (@itemid, 23, 3, 51, 10),
    (@itemid, 25, 5, 51, 10),
    (@itemid, 28, 5, 51, 10),
    (@itemid, 30, 10, 51, 10),
    (@itemid, 31, 10, 51, 10),
    (@itemid, 73, 1, 51, 10),
    (@itemid, 160, -30, 51, 10),
    (@itemid, 170, 1, 51, 10),
    (@itemid, 370, 1, 51, 10),
    (@itemid, 384, 10, 51, 10),

    -- Lv.20
    (@itemid, 287, 23, 51, 20),
    (@itemid, 2, 8, 51, 20),
    (@itemid, 5, 20, 51, 20),
    (@itemid, 8, 1, 51, 20),
    (@itemid, 9, 1, 51, 20),
    (@itemid, 13, 6, 51, 20),
    (@itemid, 14, 4, 51, 20),
    (@itemid, 23, 4, 51, 20),
    (@itemid, 25, 6, 51, 20),
    (@itemid, 28, 6, 51, 20),
    (@itemid, 30, 12, 51, 20),
    (@itemid, 31, 15, 51, 20),
    (@itemid, 73, 1, 51, 20),
    (@itemid, 160, -30, 51, 20),
    (@itemid, 170, 1, 51, 20),
    (@itemid, 384, 10, 51, 20),

    -- Lv.30
    (@itemid, 287, 25, 51, 30),
    (@itemid, 2, 15, 51, 30),
    (@itemid, 5, 30, 51, 30),
    (@itemid, 8, 2, 51, 30),
    (@itemid, 9, 2, 51, 30),
    (@itemid, 13, 8, 51, 30),
    (@itemid, 14, 5, 51, 30),
    (@itemid, 23, 6, 51, 30),
    (@itemid, 25, 9, 51, 30),
    (@itemid, 28, 8, 51, 30),
    (@itemid, 30, 20, 51, 30),
    (@itemid, 31, 20, 51, 30),
    (@itemid, 73, 1, 51, 30),
    (@itemid, 160, -50, 51, 30),
    (@itemid, 170, 1, 51, 30),
    (@itemid, 369, 1, 51, 30),
    (@itemid, 370, 1, 51, 30),
    (@itemid, 384, 15, 51, 30),

    -- Lv.40
    (@itemid, 287, 30, 51, 40),
    (@itemid, 2, 18, 51, 40),
    (@itemid, 5, 35, 51, 40),
    (@itemid, 8, 2, 51, 40),
    (@itemid, 9, 2, 51, 40),
    (@itemid, 13, 9, 51, 40),
    (@itemid, 14, 6, 51, 40),
    (@itemid, 23, 8, 51, 40),
    (@itemid, 25, 12, 51, 40),
    (@itemid, 28, 10, 51, 40),
    (@itemid, 30, 25, 51, 40),
    (@itemid, 31, 25, 51, 40),
    (@itemid, 73, 1, 51, 40),
    (@itemid, 160, -60, 51, 40),
    (@itemid, 170, 1, 51, 40),
    (@itemid, 370, 1, 51, 40),
    (@itemid, 384, 15, 51, 40),

    -- Lv.50
    (@itemid, 287, 30, 51, 50),
    (@itemid, 2, 20, 51, 50),
    (@itemid, 5, 35, 51, 50),
    (@itemid, 8, 2, 51, 50),
    (@itemid, 9, 2, 51, 50),
    (@itemid, 13, 10, 51, 50),
    (@itemid, 14, 7, 51, 50),
    (@itemid, 23, 10, 51, 50),
    (@itemid, 25, 14, 51, 50),
    (@itemid, 28, 12, 51, 50),
    (@itemid, 30, 30, 51, 50),
    (@itemid, 31, 30, 51, 50),
    (@itemid, 73, 2, 51, 50),
    (@itemid, 160, -70, 51, 50),
    (@itemid, 170, 1, 51, 50),
    (@itemid, 369, 1, 51, 50),
    (@itemid, 384, 20, 51, 50),

    -- Lv.60
    (@itemid, 287, 30, 51, 60),
    (@itemid, 2, 24, 51, 60),
    (@itemid, 5, 35, 51, 60),
    (@itemid, 8, 3, 51, 60),
    (@itemid, 9, 3, 51, 60),
    (@itemid, 13, 10, 51, 60),
    (@itemid, 14, 7, 51, 60),
    (@itemid, 23, 12, 51, 60),
    (@itemid, 25, 16, 51, 60),
    (@itemid, 28, 14, 51, 60),
    (@itemid, 30, 35, 51, 60),
    (@itemid, 31, 35, 51, 60),
    (@itemid, 73, 2, 51, 60),
    (@itemid, 160, -80, 51, 60),
    (@itemid, 170, 1, 51, 60),
    (@itemid, 370, 1, 51, 60),
    (@itemid, 384, 20, 51, 60),

    -- Lv.70
    (@itemid, 287, 30, 51, 70),
    (@itemid, 2, 25, 51, 70),
    (@itemid, 5, 25, 51, 70),
    (@itemid, 8, 3, 51, 70),
    (@itemid, 9, 3, 51, 70),
    (@itemid, 13, 9, 51, 70),
    (@itemid, 14, 7, 51, 70),
    (@itemid, 23, 12, 51, 70),
    (@itemid, 25, 16, 51, 70),
    (@itemid, 28, 12, 51, 70),
    (@itemid, 30, 30, 51, 70),
    (@itemid, 31, 30, 51, 70),
    (@itemid, 73, 2, 51, 70),
    (@itemid, 160, -80, 51, 70),
    (@itemid, 369, 1, 51, 70),
    (@itemid, 370, 1, 51, 70),
    (@itemid, 384, 20, 51, 70),

    -- Lv.80
    (@itemid, 287, 25, 51, 80),
    (@itemid, 2, 22, 51, 80),
    (@itemid, 5, 20, 51, 80),
    (@itemid, 8, 2, 51, 80),
    (@itemid, 9, 2, 51, 80),
    (@itemid, 13, 7, 51, 80),
    (@itemid, 14, 6, 51, 80),
    (@itemid, 23, 10, 51, 80),
    (@itemid, 25, 14, 51, 80),
    (@itemid, 28, 8, 51, 80),
    (@itemid, 30, 22, 51, 80),
    (@itemid, 31, 25, 51, 80),
    (@itemid, 73, 2, 51, 80),
    (@itemid, 160, -70, 51, 80),
    (@itemid, 370, 1, 51, 80),
    (@itemid, 384, 15, 51, 80),

    -- Lv.90
    (@itemid, 287, 20, 51, 90),
    (@itemid, 2, 20, 51, 90),
    (@itemid, 5, 15, 51, 90),
    (@itemid, 8, 2, 51, 90),
    (@itemid, 9, 2, 51, 90),
    (@itemid, 13, 5, 51, 90),
    (@itemid, 14, 5, 51, 90),
    (@itemid, 23, 10, 51, 90),
    (@itemid, 25, 14, 51, 90),
    (@itemid, 28, 6, 51, 90),
    (@itemid, 30, 17, 51, 90),
    (@itemid, 31, 20, 51, 90),
    (@itemid, 73, 1, 51, 90),
    (@itemid, 160, -65, 51, 90),
    (@itemid, 170, 1, 51, 90),
    (@itemid, 384, 15, 51, 90),

    -- Lv.99
    (@itemid, 287, 15, 51, 99),
    (@itemid, 2, 20, 51, 99),
    (@itemid, 5, 15, 51, 99),
    (@itemid, 8, 2, 51, 99),
    (@itemid, 9, 2, 51, 99),
    (@itemid, 13, 4, 51, 99),
    (@itemid, 14, 4, 51, 99),
    (@itemid, 23, 10, 51, 99),
    (@itemid, 25, 14, 51, 99),
    (@itemid, 28, 4, 51, 99),
    (@itemid, 30, 12, 51, 99),
    (@itemid, 31, 10, 51, 99),
    (@itemid, 73, 2, 51, 99),
    (@itemid, 160, -65, 51, 99),
    (@itemid, 170, 1, 51, 99),
    (@itemid, 369, 1, 51, 99),
    (@itemid, 370, 1, 51, 99),
    (@itemid, 384, 10, 51, 99);
