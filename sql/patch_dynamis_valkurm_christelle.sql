-- BUG: Dynamis Valkurm Cirrate/Arch Christelle (retail-style skills + weakening items)
-- Safe to run multiple times (INSERT IGNORE + UPDATE).

INSERT IGNORE INTO `mob_skill_lists` VALUES ('Cirrate_Christelle',2010,1604);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Cirrate_Christelle',2010,1606);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Cirrate_Christelle',2010,1608);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Cirrate_Christelle',2010,1610);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Cirrate_Christelle',2010,1337);

INSERT IGNORE INTO `mob_skill_lists` VALUES ('Arch_Christelle',2099,316);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Arch_Christelle',2099,317);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Arch_Christelle',2099,319);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Arch_Christelle',2099,320);
INSERT IGNORE INTO `mob_skill_lists` VALUES ('Arch_Christelle',2099,1337);

UPDATE `mob_pools` SET `skill_list_id` = 2099 WHERE `poolid` = 354 AND `name` = 'Arch_Christelle';

UPDATE `item_usable` SET `validTargets` = 4 WHERE `itemid` IN (5895, 5896, 5897);
