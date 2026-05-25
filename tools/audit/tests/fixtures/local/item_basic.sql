DROP TABLE IF EXISTS `item_basic`;
CREATE TABLE `item_basic` (`itemid` smallint(5) unsigned NOT NULL,`subid` smallint(4) unsigned NOT NULL DEFAULT 0,`name` tinytext NOT NULL,`sortname` tinytext NOT NULL,`type` tinyint(1) unsigned NOT NULL DEFAULT @GENERAL_TYPE,`stackSize` tinyint(2) unsigned NOT NULL DEFAULT 1,`flags` smallint(5) unsigned NOT NULL DEFAULT 0,`aH` tinyint(2) unsigned NOT NULL DEFAULT 99,`BaseSell` int(10) unsigned NOT NULL DEFAULT 0) ENGINE=Aria;
INSERT INTO `item_basic` VALUES (1000,0,'goblin_tooth','goblin_tooth',@GENERAL_TYPE,12,0,99,1);
INSERT INTO `item_basic` VALUES (1001,0,'goblin_armor','goblin_armor',@GENERAL_TYPE,1,0,99,5);
INSERT INTO `item_basic` VALUES (2000,0,'crab_shell','crab_shell',@GENERAL_TYPE,12,0,99,1);
