DROP TABLE IF EXISTS `mob_groups`;
CREATE TABLE `mob_groups` (`groupid` int(10) unsigned NOT NULL,`poolid` int(10) unsigned NOT NULL DEFAULT 0,`zoneid` smallint(3) unsigned NOT NULL DEFAULT 0,`name` varchar(24) DEFAULT NULL,`respawntime` int(10) unsigned NOT NULL DEFAULT 0,`spawntype` tinyint(3) unsigned NOT NULL DEFAULT 0,`dropid` int(10) unsigned NOT NULL DEFAULT 0,`HP` mediumint(8) NOT NULL DEFAULT 0,`MP` mediumint(8) NOT NULL DEFAULT 0,`allegiance` tinyint(2) unsigned NOT NULL DEFAULT 0,`content_tag` varchar(14) DEFAULT NULL) ENGINE=Aria;
INSERT INTO `mob_groups` VALUES (1000,100,1,'Goblin_Tinkerer',0,0,1,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (1001,101,1,'River_Crab',0,0,2,0,0,0,NULL);
