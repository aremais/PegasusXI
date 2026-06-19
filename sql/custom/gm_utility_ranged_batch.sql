-- GM Utility / Ranged Batch
--
-- 18823 Volos Strap      -> GM Mage Grip
-- 22198 Potent Grip      -> GM Melee Grip
-- 17851 Storm Fife       -> GM Wind Instrument
-- 18831 Crooner's Cithara-> GM String Instrument
-- 22154 Silver Gun +1    -> GM Gun
-- 19232 Octant           -> GM Octant
--
-- Notes:
--   Grips and instruments are stat utility pieces; no DMG_RATING scaling.
--   Gun and Octant use DMG_RATING modId 287 for hidden level-scaled damage.
--   latentId 51 = JOB_LEVEL_ABOVE.
--   Client DAT may still show original item names/help text until DAT edits are made.

-- ============================================================
-- 18823 Volos Strap -> GM Mage Grip
-- ============================================================

SET @mageGrip := 18823;

UPDATE item_basic
SET
    name = 'gm_mage_grip',
    sortname = 'gm_mage_grip',
    name_jp = 'GM Mage Grip',
    flags = 63552,
    aH = 0,
    BaseSell = 0
WHERE itemid = @mageGrip;

UPDATE item_equipment
SET
    name = 'gm_mage_grip',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 0,
    slot = 2,
    su_level = 0
WHERE itemId = @mageGrip;

UPDATE item_weapon
SET
    name = 'gm_mage_grip',
    skill = 0,
    subskill = 0,
    dmgType = 1,
    hit = 1,
    delay = 0,
    dmg = 0,
    unlock_points = 0
WHERE itemId = @mageGrip;

DELETE FROM item_mods WHERE itemId = @mageGrip;
DELETE FROM item_latents WHERE itemId = @mageGrip;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@mageGrip, 5, 10),    -- MP
    (@mageGrip, 12, 1),    -- INT
    (@mageGrip, 13, 1),    -- MND
    (@mageGrip, 30, 2),    -- MACC
    (@mageGrip, 163, -25); -- Magic damage taken

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@mageGrip, 5, 10, 51, 10), (@mageGrip, 12, 2, 51, 10), (@mageGrip, 13, 2, 51, 10), (@mageGrip, 28, 5, 51, 10), (@mageGrip, 30, 8, 51, 10), (@mageGrip, 31, 8, 51, 10), (@mageGrip, 163, -25, 51, 10), (@mageGrip, 170, 1, 51, 10),
    (@mageGrip, 5, 15, 51, 20), (@mageGrip, 12, 3, 51, 20), (@mageGrip, 13, 3, 51, 20), (@mageGrip, 28, 8, 51, 20), (@mageGrip, 30, 12, 51, 20), (@mageGrip, 31, 10, 51, 20), (@mageGrip, 163, -25, 51, 20),
    (@mageGrip, 5, 25, 51, 30), (@mageGrip, 12, 4, 51, 30), (@mageGrip, 13, 4, 51, 30), (@mageGrip, 28, 12, 51, 30), (@mageGrip, 30, 18, 51, 30), (@mageGrip, 31, 15, 51, 30), (@mageGrip, 163, -40, 51, 30), (@mageGrip, 170, 1, 51, 30), (@mageGrip, 369, 1, 51, 30),
    (@mageGrip, 5, 30, 51, 40), (@mageGrip, 12, 5, 51, 40), (@mageGrip, 13, 5, 51, 40), (@mageGrip, 28, 15, 51, 40), (@mageGrip, 30, 22, 51, 40), (@mageGrip, 31, 18, 51, 40), (@mageGrip, 163, -50, 51, 40),
    (@mageGrip, 5, 35, 51, 50), (@mageGrip, 12, 6, 51, 50), (@mageGrip, 13, 6, 51, 50), (@mageGrip, 28, 18, 51, 50), (@mageGrip, 30, 28, 51, 50), (@mageGrip, 31, 22, 51, 50), (@mageGrip, 163, -60, 51, 50), (@mageGrip, 170, 1, 51, 50),
    (@mageGrip, 5, 40, 51, 60), (@mageGrip, 12, 7, 51, 60), (@mageGrip, 13, 7, 51, 60), (@mageGrip, 28, 22, 51, 60), (@mageGrip, 30, 35, 51, 60), (@mageGrip, 31, 28, 51, 60), (@mageGrip, 163, -70, 51, 60), (@mageGrip, 369, 1, 51, 60),
    (@mageGrip, 5, 30, 51, 70), (@mageGrip, 12, 6, 51, 70), (@mageGrip, 13, 6, 51, 70), (@mageGrip, 28, 18, 51, 70), (@mageGrip, 30, 28, 51, 70), (@mageGrip, 31, 24, 51, 70), (@mageGrip, 163, -65, 51, 70),
    (@mageGrip, 5, 25, 51, 80), (@mageGrip, 12, 4, 51, 80), (@mageGrip, 13, 4, 51, 80), (@mageGrip, 28, 12, 51, 80), (@mageGrip, 30, 22, 51, 80), (@mageGrip, 31, 18, 51, 80), (@mageGrip, 163, -55, 51, 80), (@mageGrip, 170, 1, 51, 80),
    (@mageGrip, 5, 20, 51, 90), (@mageGrip, 12, 3, 51, 90), (@mageGrip, 13, 3, 51, 90), (@mageGrip, 28, 10, 51, 90), (@mageGrip, 30, 18, 51, 90), (@mageGrip, 31, 12, 51, 90), (@mageGrip, 163, -45, 51, 90),
    (@mageGrip, 5, 20, 51, 99), (@mageGrip, 12, 4, 51, 99), (@mageGrip, 13, 4, 51, 99), (@mageGrip, 28, 10, 51, 99), (@mageGrip, 30, 17, 51, 99), (@mageGrip, 31, 15, 51, 99), (@mageGrip, 163, -40, 51, 99), (@mageGrip, 170, 1, 51, 99), (@mageGrip, 369, 1, 51, 99);

-- ============================================================
-- 22198 Potent Grip -> GM Melee Grip
-- ============================================================

SET @meleeGrip := 22198;

UPDATE item_basic
SET
    name = 'gm_melee_grip',
    sortname = 'gm_melee_grip',
    name_jp = 'GM Melee Grip',
    aH = 0,
    BaseSell = 0
WHERE itemid = @meleeGrip;

UPDATE item_equipment
SET
    name = 'gm_melee_grip',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 0,
    slot = 2,
    su_level = 0
WHERE itemId = @meleeGrip;

UPDATE item_weapon
SET
    name = 'gm_melee_grip',
    skill = 0,
    subskill = 0,
    dmgType = 1,
    hit = 1,
    delay = 0,
    dmg = 0,
    unlock_points = 0
WHERE itemId = @meleeGrip;

DELETE FROM item_mods WHERE itemId = @meleeGrip;
DELETE FROM item_latents WHERE itemId = @meleeGrip;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@meleeGrip, 8, 1),  -- STR
    (@meleeGrip, 9, 1),  -- DEX
    (@meleeGrip, 23, 2), -- ATT
    (@meleeGrip, 25, 2); -- ACC

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@meleeGrip, 2, 5, 51, 10), (@meleeGrip, 8, 2, 51, 10), (@meleeGrip, 9, 2, 51, 10), (@meleeGrip, 10, 1, 51, 10), (@meleeGrip, 23, 6, 51, 10), (@meleeGrip, 25, 6, 51, 10), (@meleeGrip, 73, 1, 51, 10),
    (@meleeGrip, 2, 5, 51, 20), (@meleeGrip, 8, 3, 51, 20), (@meleeGrip, 9, 3, 51, 20), (@meleeGrip, 10, 2, 51, 20), (@meleeGrip, 23, 8, 51, 20), (@meleeGrip, 25, 8, 51, 20), (@meleeGrip, 73, 1, 51, 20), (@meleeGrip, 288, 1, 51, 20),
    (@meleeGrip, 2, 10, 51, 30), (@meleeGrip, 8, 4, 51, 30), (@meleeGrip, 9, 4, 51, 30), (@meleeGrip, 10, 3, 51, 30), (@meleeGrip, 23, 12, 51, 30), (@meleeGrip, 25, 12, 51, 30), (@meleeGrip, 73, 2, 51, 30), (@meleeGrip, 160, -20, 51, 30),
    (@meleeGrip, 2, 12, 51, 40), (@meleeGrip, 8, 5, 51, 40), (@meleeGrip, 9, 5, 51, 40), (@meleeGrip, 10, 4, 51, 40), (@meleeGrip, 23, 15, 51, 40), (@meleeGrip, 25, 15, 51, 40), (@meleeGrip, 73, 2, 51, 40), (@meleeGrip, 160, -30, 51, 40), (@meleeGrip, 288, 1, 51, 40),
    (@meleeGrip, 2, 15, 51, 50), (@meleeGrip, 8, 6, 51, 50), (@meleeGrip, 9, 6, 51, 50), (@meleeGrip, 10, 5, 51, 50), (@meleeGrip, 23, 18, 51, 50), (@meleeGrip, 25, 18, 51, 50), (@meleeGrip, 73, 3, 51, 50), (@meleeGrip, 160, -40, 51, 50),
    (@meleeGrip, 2, 18, 51, 60), (@meleeGrip, 8, 7, 51, 60), (@meleeGrip, 9, 7, 51, 60), (@meleeGrip, 10, 5, 51, 60), (@meleeGrip, 23, 22, 51, 60), (@meleeGrip, 25, 22, 51, 60), (@meleeGrip, 73, 3, 51, 60), (@meleeGrip, 160, -50, 51, 60), (@meleeGrip, 288, 1, 51, 60),
    (@meleeGrip, 2, 20, 51, 70), (@meleeGrip, 8, 7, 51, 70), (@meleeGrip, 9, 7, 51, 70), (@meleeGrip, 10, 5, 51, 70), (@meleeGrip, 23, 20, 51, 70), (@meleeGrip, 25, 20, 51, 70), (@meleeGrip, 73, 3, 51, 70), (@meleeGrip, 160, -50, 51, 70),
    (@meleeGrip, 2, 18, 51, 80), (@meleeGrip, 8, 5, 51, 80), (@meleeGrip, 9, 5, 51, 80), (@meleeGrip, 10, 4, 51, 80), (@meleeGrip, 23, 18, 51, 80), (@meleeGrip, 25, 18, 51, 80), (@meleeGrip, 73, 2, 51, 80), (@meleeGrip, 160, -45, 51, 80), (@meleeGrip, 288, 1, 51, 80),
    (@meleeGrip, 2, 15, 51, 90), (@meleeGrip, 8, 4, 51, 90), (@meleeGrip, 9, 4, 51, 90), (@meleeGrip, 10, 3, 51, 90), (@meleeGrip, 23, 15, 51, 90), (@meleeGrip, 25, 15, 51, 90), (@meleeGrip, 73, 2, 51, 90), (@meleeGrip, 160, -35, 51, 90),
    (@meleeGrip, 2, 12, 51, 99), (@meleeGrip, 8, 5, 51, 99), (@meleeGrip, 9, 5, 51, 99), (@meleeGrip, 10, 3, 51, 99), (@meleeGrip, 23, 14, 51, 99), (@meleeGrip, 25, 14, 51, 99), (@meleeGrip, 73, 2, 51, 99), (@meleeGrip, 160, -30, 51, 99), (@meleeGrip, 288, 1, 51, 99);

-- ============================================================
-- 17851 Storm Fife -> GM Wind Instrument
-- ============================================================

SET @windInst := 17851;

UPDATE item_basic
SET
    name = 'gm_wind_instrument',
    sortname = 'gm_wind_instrument',
    name_jp = 'GM Wind Instrument',
    aH = 0,
    BaseSell = 0
WHERE itemid = @windInst;

UPDATE item_equipment
SET
    name = 'gm_wind_instrument',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 67,
    slot = 4,
    su_level = 0
WHERE itemId = @windInst;

UPDATE item_weapon
SET
    name = 'gm_wind_instrument',
    skill = 42,
    subskill = 0,
    dmgType = 0,
    hit = 1,
    delay = 240,
    dmg = 0,
    unlock_points = 0
WHERE itemId = @windInst;

DELETE FROM item_mods WHERE itemId = @windInst;
DELETE FROM item_latents WHERE itemId = @windInst;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@windInst, 14, 2),  -- CHR
    (@windInst, 30, 2),  -- MACC
    (@windInst, 442, 1); -- Ballad

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@windInst, 5, 10, 51, 10), (@windInst, 13, 1, 51, 10), (@windInst, 14, 3, 51, 10), (@windInst, 30, 8, 51, 10), (@windInst, 31, 8, 51, 10), (@windInst, 170, 1, 51, 10),
    (@windInst, 5, 10, 51, 20), (@windInst, 13, 2, 51, 20), (@windInst, 14, 4, 51, 20), (@windInst, 30, 10, 51, 20), (@windInst, 31, 10, 51, 20), (@windInst, 369, 1, 51, 20),
    (@windInst, 5, 15, 51, 30), (@windInst, 13, 3, 51, 30), (@windInst, 14, 5, 51, 30), (@windInst, 30, 15, 51, 30), (@windInst, 31, 15, 51, 30), (@windInst, 170, 1, 51, 30),
    (@windInst, 5, 20, 51, 40), (@windInst, 13, 3, 51, 40), (@windInst, 14, 6, 51, 40), (@windInst, 30, 18, 51, 40), (@windInst, 31, 18, 51, 40), (@windInst, 370, 1, 51, 40),
    (@windInst, 5, 25, 51, 50), (@windInst, 13, 4, 51, 50), (@windInst, 14, 7, 51, 50), (@windInst, 30, 22, 51, 50), (@windInst, 31, 22, 51, 50), (@windInst, 442, 1, 51, 50),
    (@windInst, 5, 25, 51, 60), (@windInst, 13, 4, 51, 60), (@windInst, 14, 7, 51, 60), (@windInst, 30, 25, 51, 60), (@windInst, 31, 25, 51, 60), (@windInst, 170, 1, 51, 60), (@windInst, 369, 1, 51, 60),
    (@windInst, 5, 20, 51, 70), (@windInst, 13, 3, 51, 70), (@windInst, 14, 6, 51, 70), (@windInst, 30, 22, 51, 70), (@windInst, 31, 22, 51, 70),
    (@windInst, 5, 15, 51, 80), (@windInst, 13, 3, 51, 80), (@windInst, 14, 5, 51, 80), (@windInst, 30, 18, 51, 80), (@windInst, 31, 18, 51, 80), (@windInst, 370, 1, 51, 80),
    (@windInst, 5, 15, 51, 90), (@windInst, 13, 2, 51, 90), (@windInst, 14, 4, 51, 90), (@windInst, 30, 15, 51, 90), (@windInst, 31, 15, 51, 90), (@windInst, 170, 1, 51, 90),
    (@windInst, 5, 15, 51, 99), (@windInst, 13, 3, 51, 99), (@windInst, 14, 6, 51, 99), (@windInst, 30, 17, 51, 99), (@windInst, 31, 17, 51, 99), (@windInst, 369, 1, 51, 99);

-- ============================================================
-- 18831 Crooner's Cithara -> GM String Instrument
-- ============================================================

SET @stringInst := 18831;

UPDATE item_basic
SET
    name = 'gm_string_instrument',
    sortname = 'gm_string_instrument',
    name_jp = 'GM String Instrument',
    aH = 0,
    BaseSell = 0
WHERE itemid = @stringInst;

UPDATE item_equipment
SET
    name = 'gm_string_instrument',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 81,
    slot = 4,
    su_level = 0
WHERE itemId = @stringInst;

UPDATE item_weapon
SET
    name = 'gm_string_instrument',
    skill = 41,
    subskill = 0,
    dmgType = 0,
    hit = 1,
    delay = 240,
    dmg = 0,
    unlock_points = 0
WHERE itemId = @stringInst;

DELETE FROM item_mods WHERE itemId = @stringInst;
DELETE FROM item_latents WHERE itemId = @stringInst;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@stringInst, 5, 20),   -- MP
    (@stringInst, 14, 2),   -- CHR
    (@stringInst, 30, 2),   -- MACC
    (@stringInst, 442, 1);  -- Ballad

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@stringInst, 5, 15, 51, 10), (@stringInst, 12, 1, 51, 10), (@stringInst, 13, 1, 51, 10), (@stringInst, 14, 3, 51, 10), (@stringInst, 28, 3, 51, 10), (@stringInst, 30, 8, 51, 10), (@stringInst, 31, 10, 51, 10), (@stringInst, 170, 1, 51, 10),
    (@stringInst, 5, 20, 51, 20), (@stringInst, 12, 2, 51, 20), (@stringInst, 13, 2, 51, 20), (@stringInst, 14, 4, 51, 20), (@stringInst, 28, 5, 51, 20), (@stringInst, 30, 12, 51, 20), (@stringInst, 31, 14, 51, 20),
    (@stringInst, 5, 25, 51, 30), (@stringInst, 12, 3, 51, 30), (@stringInst, 13, 3, 51, 30), (@stringInst, 14, 5, 51, 30), (@stringInst, 28, 7, 51, 30), (@stringInst, 30, 18, 51, 30), (@stringInst, 31, 18, 51, 30), (@stringInst, 369, 1, 51, 30),
    (@stringInst, 5, 30, 51, 40), (@stringInst, 12, 4, 51, 40), (@stringInst, 13, 4, 51, 40), (@stringInst, 14, 6, 51, 40), (@stringInst, 28, 8, 51, 40), (@stringInst, 30, 22, 51, 40), (@stringInst, 31, 22, 51, 40), (@stringInst, 170, 1, 51, 40),
    (@stringInst, 5, 35, 51, 50), (@stringInst, 12, 5, 51, 50), (@stringInst, 13, 5, 51, 50), (@stringInst, 14, 7, 51, 50), (@stringInst, 28, 10, 51, 50), (@stringInst, 30, 28, 51, 50), (@stringInst, 31, 28, 51, 50), (@stringInst, 442, 1, 51, 50),
    (@stringInst, 5, 35, 51, 60), (@stringInst, 12, 5, 51, 60), (@stringInst, 13, 5, 51, 60), (@stringInst, 14, 7, 51, 60), (@stringInst, 28, 10, 51, 60), (@stringInst, 30, 30, 51, 60), (@stringInst, 31, 30, 51, 60), (@stringInst, 369, 1, 51, 60),
    (@stringInst, 5, 30, 51, 70), (@stringInst, 12, 4, 51, 70), (@stringInst, 13, 4, 51, 70), (@stringInst, 14, 6, 51, 70), (@stringInst, 28, 8, 51, 70), (@stringInst, 30, 26, 51, 70), (@stringInst, 31, 26, 51, 70),
    (@stringInst, 5, 25, 51, 80), (@stringInst, 12, 3, 51, 80), (@stringInst, 13, 3, 51, 80), (@stringInst, 14, 5, 51, 80), (@stringInst, 28, 6, 51, 80), (@stringInst, 30, 22, 51, 80), (@stringInst, 31, 22, 51, 80), (@stringInst, 170, 1, 51, 80),
    (@stringInst, 5, 20, 51, 90), (@stringInst, 12, 2, 51, 90), (@stringInst, 13, 2, 51, 90), (@stringInst, 14, 4, 51, 90), (@stringInst, 28, 5, 51, 90), (@stringInst, 30, 18, 51, 90), (@stringInst, 31, 18, 51, 90),
    (@stringInst, 5, 20, 51, 99), (@stringInst, 12, 3, 51, 99), (@stringInst, 13, 3, 51, 99), (@stringInst, 14, 6, 51, 99), (@stringInst, 28, 8, 51, 99), (@stringInst, 30, 14, 51, 99), (@stringInst, 31, 17, 51, 99), (@stringInst, 369, 1, 51, 99);

-- ============================================================
-- 22154 Silver Gun +1 -> GM Gun
-- ============================================================

SET @gun := 22154;

UPDATE item_basic
SET
    name = 'gm_gun',
    sortname = 'gm_gun',
    name_jp = 'GM Gun',
    aH = 0,
    BaseSell = 0
WHERE itemid = @gun;

UPDATE item_equipment
SET
    name = 'gm_gun',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 139,
    slot = 4,
    su_level = 0
WHERE itemId = @gun;

UPDATE item_weapon
SET
    name = 'gm_gun',
    skill = 26,
    subskill = 1,
    dmgType = 1,
    hit = 1,
    delay = 582,
    dmg = 6,
    unlock_points = 0
WHERE itemId = @gun;

DELETE FROM item_mods WHERE itemId = @gun;
DELETE FROM item_latents WHERE itemId = @gun;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@gun, 26, 2),   -- RACC
    (@gun, 24, 2),   -- RATT
    (@gun, 305, 5),  -- Recycle
    (@gun, 365, 5);  -- Snapshot

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@gun, 287, 34, 51, 10), (@gun, 11, 3, 51, 10), (@gun, 24, 10, 51, 10), (@gun, 26, 10, 51, 10), (@gun, 73, 1, 51, 10), (@gun, 305, 3, 51, 10), (@gun, 365, 3, 51, 10),
    (@gun, 287, 40, 51, 20), (@gun, 11, 4, 51, 20), (@gun, 24, 12, 51, 20), (@gun, 26, 12, 51, 20), (@gun, 73, 1, 51, 20), (@gun, 305, 3, 51, 20), (@gun, 365, 3, 51, 20),
    (@gun, 287, 45, 51, 30), (@gun, 9, 2, 51, 30), (@gun, 11, 5, 51, 30), (@gun, 24, 18, 51, 30), (@gun, 26, 18, 51, 30), (@gun, 73, 2, 51, 30), (@gun, 305, 4, 51, 30), (@gun, 365, 4, 51, 30),
    (@gun, 287, 45, 51, 40), (@gun, 9, 3, 51, 40), (@gun, 11, 6, 51, 40), (@gun, 24, 22, 51, 40), (@gun, 26, 22, 51, 40), (@gun, 73, 2, 51, 40), (@gun, 305, 4, 51, 40), (@gun, 365, 4, 51, 40),
    (@gun, 287, 45, 51, 50), (@gun, 9, 4, 51, 50), (@gun, 11, 7, 51, 50), (@gun, 24, 28, 51, 50), (@gun, 26, 28, 51, 50), (@gun, 73, 3, 51, 50), (@gun, 305, 5, 51, 50), (@gun, 365, 5, 51, 50),
    (@gun, 287, 45, 51, 60), (@gun, 9, 5, 51, 60), (@gun, 11, 8, 51, 60), (@gun, 24, 32, 51, 60), (@gun, 26, 32, 51, 60), (@gun, 73, 3, 51, 60), (@gun, 305, 5, 51, 60), (@gun, 365, 5, 51, 60),
    (@gun, 287, 40, 51, 70), (@gun, 9, 5, 51, 70), (@gun, 11, 8, 51, 70), (@gun, 24, 30, 51, 70), (@gun, 26, 30, 51, 70), (@gun, 73, 3, 51, 70), (@gun, 305, 4, 51, 70), (@gun, 365, 4, 51, 70),
    (@gun, 287, 35, 51, 80), (@gun, 9, 4, 51, 80), (@gun, 11, 6, 51, 80), (@gun, 24, 25, 51, 80), (@gun, 26, 25, 51, 80), (@gun, 73, 2, 51, 80), (@gun, 305, 4, 51, 80), (@gun, 365, 4, 51, 80),
    (@gun, 287, 30, 51, 90), (@gun, 9, 3, 51, 90), (@gun, 11, 5, 51, 90), (@gun, 24, 20, 51, 90), (@gun, 26, 20, 51, 90), (@gun, 73, 2, 51, 90), (@gun, 305, 3, 51, 90), (@gun, 365, 3, 51, 90),
    (@gun, 287, 26, 51, 99), (@gun, 9, 2, 51, 99), (@gun, 11, 2, 51, 99), (@gun, 24, 21, 51, 99), (@gun, 26, 21, 51, 99), (@gun, 73, 1, 51, 99), (@gun, 305, 5, 51, 99), (@gun, 365, 5, 51, 99);

-- ============================================================
-- 19232 Octant -> GM Octant
-- ============================================================

SET @octant := 19232;

UPDATE item_basic
SET
    name = 'gm_octant',
    sortname = 'gm_octant',
    name_jp = 'GM Octant',
    aH = 0,
    BaseSell = 0
WHERE itemid = @octant;

UPDATE item_equipment
SET
    name = 'gm_octant',
    level = 1,
    ilevel = 0,
    jobs = 4194303,
    MId = 56,
    slot = 4,
    su_level = 0
WHERE itemId = @octant;

UPDATE item_weapon
SET
    name = 'gm_octant',
    skill = 26,
    subskill = 0,
    dmgType = 1,
    hit = 1,
    delay = 194,
    dmg = 5,
    unlock_points = 0
WHERE itemId = @octant;

DELETE FROM item_mods WHERE itemId = @octant;
DELETE FROM item_latents WHERE itemId = @octant;

INSERT INTO item_mods (itemId, modId, value) VALUES
    (@octant, 9, 1),   -- DEX
    (@octant, 11, 1),  -- AGI
    (@octant, 26, 3);  -- RACC

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    (@octant, 287, 20, 51, 10), (@octant, 9, 3, 51, 10), (@octant, 11, 3, 51, 10), (@octant, 24, 6, 51, 10), (@octant, 26, 10, 51, 10), (@octant, 68, 4, 51, 10), (@octant, 73, 1, 51, 10),
    (@octant, 287, 25, 51, 20), (@octant, 9, 4, 51, 20), (@octant, 11, 4, 51, 20), (@octant, 24, 8, 51, 20), (@octant, 26, 12, 51, 20), (@octant, 68, 5, 51, 20), (@octant, 73, 1, 51, 20),
    (@octant, 287, 30, 51, 30), (@octant, 9, 5, 51, 30), (@octant, 11, 5, 51, 30), (@octant, 24, 12, 51, 30), (@octant, 26, 18, 51, 30), (@octant, 68, 8, 51, 30), (@octant, 73, 2, 51, 30),
    (@octant, 287, 35, 51, 40), (@octant, 9, 6, 51, 40), (@octant, 11, 6, 51, 40), (@octant, 24, 15, 51, 40), (@octant, 26, 22, 51, 40), (@octant, 68, 10, 51, 40), (@octant, 73, 2, 51, 40),
    (@octant, 287, 35, 51, 50), (@octant, 9, 7, 51, 50), (@octant, 11, 7, 51, 50), (@octant, 24, 18, 51, 50), (@octant, 26, 28, 51, 50), (@octant, 68, 12, 51, 50), (@octant, 73, 3, 51, 50),
    (@octant, 287, 35, 51, 60), (@octant, 9, 8, 51, 60), (@octant, 11, 8, 51, 60), (@octant, 24, 22, 51, 60), (@octant, 26, 32, 51, 60), (@octant, 68, 15, 51, 60), (@octant, 73, 3, 51, 60),
    (@octant, 287, 30, 51, 70), (@octant, 9, 8, 51, 70), (@octant, 11, 8, 51, 70), (@octant, 24, 20, 51, 70), (@octant, 26, 30, 51, 70), (@octant, 68, 15, 51, 70), (@octant, 73, 3, 51, 70),
    (@octant, 287, 25, 51, 80), (@octant, 9, 6, 51, 80), (@octant, 11, 6, 51, 80), (@octant, 24, 18, 51, 80), (@octant, 26, 25, 51, 80), (@octant, 68, 12, 51, 80), (@octant, 73, 2, 51, 80),
    (@octant, 287, 20, 51, 90), (@octant, 9, 5, 51, 90), (@octant, 11, 5, 51, 90), (@octant, 24, 15, 51, 90), (@octant, 26, 20, 51, 90), (@octant, 68, 10, 51, 90), (@octant, 73, 2, 51, 90),
    (@octant, 287, 10, 51, 99), (@octant, 9, 2, 51, 99), (@octant, 11, 2, 51, 99), (@octant, 24, 11, 51, 99), (@octant, 26, 10, 51, 99), (@octant, 68, 9, 51, 99), (@octant, 73, 1, 51, 99);
