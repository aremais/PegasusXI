-- Synthetic mob_groups for spawn points still missing a group row after upstream sync.
-- Built from mob_pools.name lookup. Safe to re-run.

INSERT INTO `mob_groups` VALUES (45, 6121, 208, 'Uran-Mafran', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (1, 693, 278, 'Chaos', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (2, 6160, 278, 'Gloom_Phantom', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (3, 6123, 278, 'Magh_Bihu', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (4, 6124, 278, 'Dazbog', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (2, 693, 299, 'Chaos', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (5, 6160, 299, 'Gloom_Phantom', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (6, 6123, 299, 'Magh_Bihu', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (7, 6124, 299, 'Dazbog', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (16, 6160, 299, 'Gloom_Phantom', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (17, 6123, 299, 'Magh_Bihu', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
INSERT INTO `mob_groups` VALUES (18, 6124, 299, 'Dazbog', 0, 128, 0, 0, 0, 0, 0, 0, NULL) ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
