DROP TABLE IF EXISTS `mob_pools`;
CREATE TABLE `mob_pools` (
  `poolid` int(10) unsigned NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  `packet_name` varchar(24) DEFAULT NULL,
  `speciesid` smallint(4) unsigned NOT NULL DEFAULT 0,
  `modelid` binary(20) NOT NULL,
  `mJob` tinyint(2) unsigned NOT NULL DEFAULT 1,
  `sJob` tinyint(2) unsigned NOT NULL DEFAULT 1,
  `cmbSkill` tinyint(2) unsigned NOT NULL DEFAULT 1,
  `cmbDelay` smallint(3) unsigned NOT NULL DEFAULT 240,
  `cmbDmgMult` smallint(4) unsigned NOT NULL DEFAULT 100,
  `behavior` smallint(5) unsigned NOT NULL DEFAULT 0,
  `aggro` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `true_detection` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `links` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `mobType` smallint(5) unsigned NOT NULL DEFAULT 0,
  `immunity` int(10) NOT NULL DEFAULT 0,
  `name_prefix` tinyint(4) unsigned NOT NULL DEFAULT 0,
  `flag` int(11) unsigned NOT NULL DEFAULT 0,
  `entityFlags` int(11) unsigned NOT NULL DEFAULT 0,
  `animationsub` tinyint(1) NOT NULL DEFAULT 0,
  `hasSpellScript` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `spellList` smallint(4) NOT NULL DEFAULT 0,
  `namevis` tinyint(4) NOT NULL DEFAULT 1,
  `roamflag` smallint(3) unsigned NOT NULL DEFAULT 0,
  `skill_list_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `resist_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `modelSize` tinyint(1) unsigned DEFAULT NULL,
  `modelHitboxSize` tinyint(1) unsigned DEFAULT NULL,
  PRIMARY KEY (`poolid`)
) ENGINE=Aria;
INSERT INTO `mob_pools` VALUES (100,'Goblin_Tinkerer','Goblin_Tinkerer',50,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,1,0,1,0,0,0,0,3,0,0,0,0,0,12,12,1,12);
INSERT INTO `mob_pools` VALUES (101,'River_Crab','River_Crab',60,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,12);
INSERT INTO `mob_pools` VALUES (102,'Local_Only_Mob','Local_Only_Mob',70,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,12);
