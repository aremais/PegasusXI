-- Restore retail item names only.
-- This does NOT change stats, mods, latents, level, jobs, models, damage, delay, or flags.
-- Use this after GM item patches if you want the DB names back to retail while keeping GM stats.

-- ============================================================
-- GM Weapons 001-010
-- ============================================================

-- 20514 GM Knuckles -> Aphelion Knuckles
UPDATE item_basic
SET name = 'aphelion_knuckles', sortname = 'aphelion_knuckles', name_jp = 'Aphelion Knuckles'
WHERE itemid = 20514;
UPDATE item_equipment SET name = 'aphelion_knuckles' WHERE itemId = 20514;
UPDATE item_weapon SET name = 'aphelion_knuckles' WHERE itemId = 20514;

-- 20593 GM Dagger -> Hedron Dagger
UPDATE item_basic
SET name = 'hedron_dagger', sortname = 'hedron_dagger', name_jp = 'Hedron Dagger'
WHERE itemid = 20593;
UPDATE item_equipment SET name = 'hedron_dagger' WHERE itemId = 20593;
UPDATE item_weapon SET name = 'hedron_dagger' WHERE itemId = 20593;

-- 21745 GM Axe -> Dullahan Axe
UPDATE item_basic
SET name = 'dullahan_axe', sortname = 'dullahan_axe', name_jp = 'Dullahan Axe'
WHERE itemid = 21745;
UPDATE item_equipment SET name = 'dullahan_axe' WHERE itemId = 21745;
UPDATE item_weapon SET name = 'dullahan_axe' WHERE itemId = 21745;

-- 21770 GM Great Axe -> Helgoland
UPDATE item_basic
SET name = 'helgoland', sortname = 'helgoland', name_jp = 'Helgoland'
WHERE itemid = 21770;
UPDATE item_equipment SET name = 'helgoland' WHERE itemId = 21770;
UPDATE item_weapon SET name = 'helgoland' WHERE itemId = 21770;

-- 21821 GM Scythe -> Lost Sickle +1
UPDATE item_basic
SET name = 'lost_sickle_+1', sortname = 'lost_sickle_+1', name_jp = 'Lost Sickle +1'
WHERE itemid = 21821;
UPDATE item_equipment SET name = 'lost_sickle_+1' WHERE itemId = 21821;
UPDATE item_weapon SET name = 'lost_sickle_+1' WHERE itemId = 21821;

-- 20931 GM Spear -> Celestial Spear
UPDATE item_basic
SET name = 'celestial_spear', sortname = 'celestial_spear', name_jp = 'Celestial Spear'
WHERE itemid = 20931;
UPDATE item_equipment SET name = 'celestial_spear' WHERE itemId = 20931;
UPDATE item_weapon SET name = 'celestial_spear' WHERE itemId = 20931;

-- 16911 GM Katana Power -> Amanojaku
UPDATE item_basic
SET name = 'amanojaku', sortname = 'amanojaku', name_jp = 'Amanojaku'
WHERE itemid = 16911;
UPDATE item_equipment SET name = 'amanojaku' WHERE itemId = 16911;
UPDATE item_weapon SET name = 'amanojaku' WHERE itemId = 16911;

-- 16912 GM Katana Speed -> Kitsutsuki
UPDATE item_basic
SET name = 'kitsutsuki', sortname = 'kitsutsuki', name_jp = 'Kitsutsuki'
WHERE itemid = 16912;
UPDATE item_equipment SET name = 'kitsutsuki' WHERE itemId = 16912;
UPDATE item_weapon SET name = 'kitsutsuki' WHERE itemId = 16912;

-- 21024 GM Great Katana -> Ohakari
UPDATE item_basic
SET name = 'ohakari', sortname = 'ohakari', name_jp = 'Ohakari'
WHERE itemid = 21024;
UPDATE item_equipment SET name = 'ohakari' WHERE itemId = 21024;
UPDATE item_weapon SET name = 'ohakari' WHERE itemId = 21024;

-- 22070 GM Staff -> Ranine Staff
UPDATE item_basic
SET name = 'ranine_staff', sortname = 'ranine_staff', name_jp = 'Ranine Staff'
WHERE itemid = 22070;
UPDATE item_equipment SET name = 'ranine_staff' WHERE itemId = 22070;
UPDATE item_weapon SET name = 'ranine_staff' WHERE itemId = 22070;

-- 18401 GM Rod -> Moogle Rod
UPDATE item_basic
SET name = 'moogle_rod', sortname = 'moogle_rod', name_jp = 'Moogle Rod'
WHERE itemid = 18401;
UPDATE item_equipment SET name = 'moogle_rod' WHERE itemId = 18401;
UPDATE item_weapon SET name = 'moogle_rod' WHERE itemId = 18401;

-- ============================================================
-- GM Utility / Ranged Batch
-- ============================================================

-- 18823 GM Mage Grip -> Volos Strap
UPDATE item_basic
SET name = 'volos_strap', sortname = 'volos_strap', name_jp = 'Volos Strap'
WHERE itemid = 18823;
UPDATE item_equipment SET name = 'volos_strap' WHERE itemId = 18823;
UPDATE item_weapon SET name = 'volos_strap' WHERE itemId = 18823;

-- 22198 GM Melee Grip -> Potent Grip
UPDATE item_basic
SET name = 'potent_grip', sortname = 'potent_grip', name_jp = 'Potent Grip'
WHERE itemid = 22198;
UPDATE item_equipment SET name = 'potent_grip' WHERE itemId = 22198;
UPDATE item_weapon SET name = 'potent_grip' WHERE itemId = 22198;

-- 17851 GM Wind Instrument -> Storm Fife
UPDATE item_basic
SET name = 'storm_fife', sortname = 'storm_fife', name_jp = 'Storm Fife'
WHERE itemid = 17851;
UPDATE item_equipment SET name = 'storm_fife' WHERE itemId = 17851;
UPDATE item_weapon SET name = 'storm_fife' WHERE itemId = 17851;

-- 18831 GM String Instrument -> Crooner's Cithara
UPDATE item_basic
SET name = 'crooners_cithara', sortname = 'crooners_cithara', name_jp = 'Crooner''s Cithara'
WHERE itemid = 18831;
UPDATE item_equipment SET name = 'crooners_cithara' WHERE itemId = 18831;
UPDATE item_weapon SET name = 'crooners_cithara' WHERE itemId = 18831;

-- 22154 GM Gun -> Silver Gun +1
UPDATE item_basic
SET name = 'silver_gun_+1', sortname = 'silver_gun_+1', name_jp = 'Silver Gun +1'
WHERE itemid = 22154;
UPDATE item_equipment SET name = 'silver_gun+1' WHERE itemId = 22154;
UPDATE item_weapon SET name = 'silver_gun_+1' WHERE itemId = 22154;

-- 19232 GM Octant -> Octant
UPDATE item_basic
SET name = 'octant', sortname = 'octant', name_jp = 'Octant'
WHERE itemid = 19232;
UPDATE item_equipment SET name = 'octant' WHERE itemId = 19232;
UPDATE item_weapon SET name = 'octant' WHERE itemId = 19232;
