DROP TABLE IF EXISTS `mob_pool_mods`;
CREATE TABLE `mob_pool_mods` (`poolid` smallint(5) unsigned NOT NULL, `modid` smallint(5) unsigned NOT NULL, `value` smallint(5) NOT NULL DEFAULT '0', `is_mob_mod` boolean NOT NULL DEFAULT '0', PRIMARY KEY (`poolid`,`modid`)) ENGINE=Aria;
INSERT INTO `mob_pool_mods` VALUES (101,16,2,1); -- River_Crab: override detects to HEARING only
