-- Talacca Cove (57): enable fished-up mobs and fish catches
--
-- mob_groups / mob_spawn_points were present but fishing_mob rows were missing,
-- so the fishing hook pool had no monsters for this zone.
--
-- Run once against your database, then restart the map server (or reload zone 57).
-- Safe to re-run: INSERT IGNORE skips duplicates; UPDATE is idempotent.

INSERT IGNORE INTO `fishing_mob` VALUES (17010689,'Wootzshell',57,10,1,1,10,16,10,15,255,255,0,0,0,1000,0,0,0,0,0,0,0);
INSERT IGNORE INTO `fishing_mob` VALUES (17010690,'Arrapago_Leech',57,10,1,1,10,16,10,15,255,255,0,0,0,1000,0,0,0,0,0,0,0);
INSERT IGNORE INTO `fishing_mob` VALUES (17010691,'Talacca_Clot',57,10,1,1,10,16,10,15,255,255,0,0,0,1000,0,0,0,0,0,0,0);
INSERT IGNORE INTO `fishing_mob` VALUES (17010692,'Lahama',57,10,1,1,10,16,10,15,255,255,0,0,0,1000,0,0,0,0,0,0,0);
INSERT IGNORE INTO `fishing_mob` VALUES (17010693,'Llamhigyn_Y_Dwr',57,10,1,1,10,16,10,15,255,255,0,0,0,1000,0,0,0,0,0,0,0);
INSERT IGNORE INTO `fishing_mob` VALUES (17010694,'Giant_Orobon',57,50,1,1,10,15,10,15,255,255,1,0,1,1000,0,0,17407,17400,0,0,0);

UPDATE `mob_spawn_points` SET `minLevel` = 76, `maxLevel` = 77 WHERE `mobid` = 17010691;
UPDATE `mob_spawn_points` SET `minLevel` = 81, `maxLevel` = 83 WHERE `mobid` = 17010694;
