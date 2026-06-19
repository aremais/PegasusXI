-- Final mob_groups/spawn fixes for instance and campaign mobs still missing group rows.
-- Safe to re-run.

-- Ashu Talif crew spawns used groupid 0; point them at the rng crew group.
UPDATE `mob_spawn_points` SET `groupid` = 6
WHERE ((mobid >> 12) & 0xFFF) = 60 AND `groupid` = 0 AND `mobname` = 'Ashu_Talif_Crew';

INSERT INTO `mob_groups` VALUES (36, 5807, 183, 'Auspicious_Entity', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);
UPDATE `mob_spawn_points` SET `groupid` = 36
WHERE ((mobid >> 12) & 0xFFF) = 183 AND `groupid` = 0 AND `mobname` = 'Auspicious_Entity';

INSERT INTO `mob_groups` VALUES (2, 0, 229, 'Oshasha', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (3, 0, 229, 'Valli', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `mob_groups` VALUES (20, 1876, 258, 'Awoken_Hakenmann', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (45, 0, 266, 'Gramk-Droog', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (41, 2879, 267, 'Awoken_Nihhus', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);

INSERT INTO `mob_groups` VALUES (9, 5984, 277, 'August_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (10, 0, 277, 'Bztavian_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (11, 0, 277, 'Rockfin_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (12, 0, 277, 'Gabbrath_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (13, 0, 277, 'Yggdreant_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (14, 0, 277, 'Waktza_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (15, 0, 277, 'Cehuetzi_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (16, 5986, 277, 'Teodor_OB', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);

INSERT INTO `mob_groups` VALUES (92, 3782, 291, 'Awoken_Stoorworm', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (4, 4402, 299, 'Profane_Circle', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid` = VALUES(`poolid`), `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (8, 0, 299, 'Gurebu-Ogurebu', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (10, 0, 299, 'Medada', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (11, 0, 299, 'Cornelia', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (14, 0, 299, 'Fickblix', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (3, 0, 299, 'Garazu-Horeizu', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `mob_groups` VALUES (15, 0, 299, 'Paragons_Gloam', 0, 128, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
