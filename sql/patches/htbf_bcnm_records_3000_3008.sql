-- Register High-Tier Mission Battlefield (HTBF) entries in bcnm_records.
-- These rows are required for the battlefield engine to recognise the
-- protocrystal/entrance NPCs and allow player entry.
-- All fights have a 30-minute time limit (1800 seconds).
--
-- bcnmId values 3000-3008 are defined in scripts/globals/battlefield.lua.
-- Zone IDs match xi.zone.* constants in scripts/enum/zone.lua.

INSERT IGNORE INTO `bcnm_records` VALUES (3000, 207, 'trial_by_fire_htbf',      'nobody', 0, 1800); -- Cloister of Flames
INSERT IGNORE INTO `bcnm_records` VALUES (3001, 203, 'trial_by_ice_htbf',       'nobody', 0, 1800); -- Cloister of Frost
INSERT IGNORE INTO `bcnm_records` VALUES (3002, 201, 'trial_by_wind_htbf',      'nobody', 0, 1800); -- Cloister of Gales
INSERT IGNORE INTO `bcnm_records` VALUES (3003, 209, 'trial_by_earth_htbf',     'nobody', 0, 1800); -- Cloister of Tremors
INSERT IGNORE INTO `bcnm_records` VALUES (3004, 202, 'trial_by_lightning_htbf', 'nobody', 0, 1800); -- Cloister of Storms
INSERT IGNORE INTO `bcnm_records` VALUES (3005, 211, 'trial_by_water_htbf',     'nobody', 0, 1800); -- Cloister of Tides
INSERT IGNORE INTO `bcnm_records` VALUES (3006, 170, 'moonlit_path_htbf',       'nobody', 0, 1800); -- Full Moon Fountain
INSERT IGNORE INTO `bcnm_records` VALUES (3007, 170, 'waking_the_beast_htbf',   'nobody', 0, 1800); -- Full Moon Fountain
INSERT IGNORE INTO `bcnm_records` VALUES (3008,  10, 'waking_dreams_htbf',      'nobody', 0, 1800); -- The Shrouded Maw
