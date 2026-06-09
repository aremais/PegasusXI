-- GM Weapon 002: GM Dagger
-- Base item: 20593 Hedron Dagger
-- Purpose: Rare/Ex special-appearance GM Dagger weapon.
-- Appearance:
--   Uses Hedron Dagger visual behavior.
--   Lightsaber-style blade appears when drawn.
--
-- Notes:
--   Server-side name is changed to gm_dagger.
--   Client DAT may still show original item name/help text until DAT edits are made.
--   Keeps Level 1 + All Jobs + Rare/Ex-style flags.
--   DMG_RATING modId 287 provides hidden effective weapon damage by level.
--   latentId 51 = JOB_LEVEL_ABOVE.

SET @itemid := 20593;

UPDATE item_basic
SET
    name = 'gm_dagger',
    sortname = 'gm_dagger',
    name_jp = 'GM Dagger',
    aH = 0,
    BaseSell = 0
WHERE itemid = @itemid;

UPDATE item_equipment
SET
    name = 'gm_dagger',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    slot = 3,
    su_level = 0
WHERE itemId = @itemid;

UPDATE item_weapon
SET
    name = 'gm_dagger',
    skill = 2,
    subskill = 0,
    ilvl_skill = 0,
    ilvl_parry = 0,
    ilvl_macc = 0,
    dmgType = 1,
    hit = 1,
    delay = 150,
    dmg = 3,
    unlock_points = 0
WHERE itemId = @itemid;

DELETE FROM item_mods
WHERE itemId = @itemid;

DELETE FROM item_latents
WHERE itemId = @itemid;

-- Lv.1 starter stats.
INSERT INTO item_mods (itemId, modId, value) VALUES
    (@itemid, 25, 1), -- ACC +1
    (@itemid, 68, 1); -- EVA +1

-- Final Lv.99 totals:
-- Effective DMG 250 = base 3 + hidden DMG_RATING 247
-- HP+120
-- STR+25, DEX+45, AGI+35
-- ATT+120, ACC+171 including base ACC+1
-- EVA+81 including base EVA+1
-- Store TP+20
-- Damage Taken -4%
-- Double Attack+8
-- Haste Gear +4%

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- Lv.10
    (@itemid, 287, 17, 51, 10),
    (@itemid, 2, 6, 51, 10),
    (@itemid, 8, 1, 51, 10),
    (@itemid, 9, 3, 51, 10),
    (@itemid, 11, 2, 51, 10),
    (@itemid, 23, 6, 51, 10),
    (@itemid, 25, 8, 51, 10),
    (@itemid, 68, 4, 51, 10),
    (@itemid, 73, 1, 51, 10),
    (@itemid, 160, -20, 51, 10),
    (@itemid, 288, 1, 51, 10),
    (@itemid, 384, 20, 51, 10),

    -- Lv.20
    (@itemid, 287, 22, 51, 20),
    (@itemid, 2, 6, 51, 20),
    (@itemid, 8, 2, 51, 20),
    (@itemid, 9, 4, 51, 20),
    (@itemid, 11, 3, 51, 20),
    (@itemid, 23, 6, 51, 20),
    (@itemid, 25, 8, 51, 20),
    (@itemid, 68, 4, 51, 20),
    (@itemid, 73, 1, 51, 20),
    (@itemid, 160, -20, 51, 20),
    (@itemid, 384, 20, 51, 20),

    -- Lv.30
    (@itemid, 287, 23, 51, 30),
    (@itemid, 2, 10, 51, 30),
    (@itemid, 8, 2, 51, 30),
    (@itemid, 9, 5, 51, 30),
    (@itemid, 11, 4, 51, 30),
    (@itemid, 23, 10, 51, 30),
    (@itemid, 25, 14, 51, 30),
    (@itemid, 68, 7, 51, 30),
    (@itemid, 73, 2, 51, 30),
    (@itemid, 160, -32, 51, 30),
    (@itemid, 288, 1, 51, 30),
    (@itemid, 384, 32, 51, 30),

    -- Lv.40
    (@itemid, 287, 25, 51, 40),
    (@itemid, 2, 12, 51, 40),
    (@itemid, 8, 3, 51, 40),
    (@itemid, 9, 6, 51, 40),
    (@itemid, 11, 5, 51, 40),
    (@itemid, 23, 12, 51, 40),
    (@itemid, 25, 17, 51, 40),
    (@itemid, 68, 8, 51, 40),
    (@itemid, 73, 2, 51, 40),
    (@itemid, 160, -40, 51, 40),
    (@itemid, 288, 1, 51, 40),
    (@itemid, 384, 40, 51, 40),

    -- Lv.50
    (@itemid, 287, 25, 51, 50),
    (@itemid, 2, 14, 51, 50),
    (@itemid, 8, 3, 51, 50),
    (@itemid, 9, 7, 51, 50),
    (@itemid, 11, 6, 51, 50),
    (@itemid, 23, 14, 51, 50),
    (@itemid, 25, 20, 51, 50),
    (@itemid, 68, 10, 51, 50),
    (@itemid, 73, 2, 51, 50),
    (@itemid, 160, -48, 51, 50),
    (@itemid, 288, 1, 51, 50),
    (@itemid, 384, 48, 51, 50),

    -- Lv.60
    (@itemid, 287, 30, 51, 60),
    (@itemid, 2, 16, 51, 60),
    (@itemid, 8, 3, 51, 60),
    (@itemid, 9, 7, 51, 60),
    (@itemid, 11, 6, 51, 60),
    (@itemid, 23, 16, 51, 60),
    (@itemid, 25, 23, 51, 60),
    (@itemid, 68, 11, 51, 60),
    (@itemid, 73, 3, 51, 60),
    (@itemid, 160, -52, 51, 60),
    (@itemid, 288, 1, 51, 60),
    (@itemid, 384, 52, 51, 60),

    -- Lv.70
    (@itemid, 287, 30, 51, 70),
    (@itemid, 2, 18, 51, 70),
    (@itemid, 8, 4, 51, 70),
    (@itemid, 9, 7, 51, 70),
    (@itemid, 11, 6, 51, 70),
    (@itemid, 23, 18, 51, 70),
    (@itemid, 25, 25, 51, 70),
    (@itemid, 68, 12, 51, 70),
    (@itemid, 73, 3, 51, 70),
    (@itemid, 160, -56, 51, 70),
    (@itemid, 288, 1, 51, 70),
    (@itemid, 384, 56, 51, 70),

    -- Lv.80
    (@itemid, 287, 30, 51, 80),
    (@itemid, 2, 16, 51, 80),
    (@itemid, 8, 3, 51, 80),
    (@itemid, 9, 5, 51, 80),
    (@itemid, 11, 4, 51, 80),
    (@itemid, 23, 16, 51, 80),
    (@itemid, 25, 22, 51, 80),
    (@itemid, 68, 10, 51, 80),
    (@itemid, 73, 2, 51, 80),
    (@itemid, 160, -52, 51, 80),
    (@itemid, 288, 1, 51, 80),
    (@itemid, 384, 52, 51, 80),

    -- Lv.90
    (@itemid, 287, 25, 51, 90),
    (@itemid, 2, 14, 51, 90),
    (@itemid, 8, 2, 51, 90),
    (@itemid, 9, 4, 51, 90),
    (@itemid, 11, 3, 51, 90),
    (@itemid, 23, 14, 51, 90),
    (@itemid, 25, 18, 51, 90),
    (@itemid, 68, 8, 51, 90),
    (@itemid, 73, 2, 51, 90),
    (@itemid, 160, -48, 51, 90),
    (@itemid, 288, 1, 51, 90),
    (@itemid, 384, 48, 51, 90),

    -- Lv.99
    (@itemid, 287, 10, 51, 99),
    (@itemid, 2, 8, 51, 99),
    (@itemid, 8, 5, 51, 99),
    (@itemid, 9, 7, 51, 99),
    (@itemid, 11, 6, 51, 99),
    (@itemid, 23, 8, 51, 99),
    (@itemid, 25, 7, 51, 99),
    (@itemid, 68, 5, 51, 99),
    (@itemid, 73, 2, 51, 99),
    (@itemid, 160, -32, 51, 99),
    (@itemid, 384, 32, 51, 99);
