DROP TABLE IF EXISTS `mob_droplist`;
CREATE TABLE `mob_droplist` (`dropId` smallint(5) unsigned NOT NULL, `dropType` tinyint(3) unsigned NOT NULL DEFAULT '0', `groupId` tinyint(3) unsigned NOT NULL DEFAULT '0', `groupRate` smallint(4) unsigned NOT NULL DEFAULT '1000', `itemId` smallint(5) unsigned NOT NULL DEFAULT '0', `itemRate` smallint(4) unsigned NOT NULL DEFAULT '0') ENGINE=Aria;
INSERT INTO `mob_droplist` VALUES (1,0,0,1000,1000,150); -- itemRate changed locally
INSERT INTO `mob_droplist` VALUES (1,0,0,1000,1001,200); -- matches upstream
INSERT INTO `mob_droplist` VALUES (2,0,0,1000,2000,250); -- local-only
