DROP TABLE IF EXISTS `mob_species_system`;
CREATE TABLE `mob_species_system` (
  `speciesID` smallint(4) unsigned NOT NULL,
  `species` tinytext,
  `familyID` smallint(4) unsigned NOT NULL DEFAULT 0,
  `family` tinytext,
  `ecosystemID` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `ecosystem` tinytext,
  `speed` tinyint(3) unsigned NOT NULL DEFAULT 40,
  `HP` tinyint(3) unsigned NOT NULL DEFAULT 100,
  `MP` tinyint(3) unsigned NOT NULL DEFAULT 100,
  `STR` smallint(4) unsigned NOT NULL DEFAULT 3,
  `DEX` smallint(4) unsigned NOT NULL DEFAULT 3,
  `VIT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `AGI` smallint(4) unsigned NOT NULL DEFAULT 3,
  `INT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `MND` smallint(4) unsigned NOT NULL DEFAULT 3,
  `CHR` smallint(4) unsigned NOT NULL DEFAULT 3,
  `ATT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `DEF` smallint(4) unsigned NOT NULL DEFAULT 3,
  `ACC` smallint(4) unsigned NOT NULL DEFAULT 3,
  `EVA` smallint(4) unsigned NOT NULL DEFAULT 3,
  `Element` float NOT NULL DEFAULT 0,
  `detects` smallint(5) NOT NULL DEFAULT 0,
  `charmable` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`speciesID`)
) ENGINE=Aria;
INSERT INTO `mob_species_system` VALUES (50,'Goblin',50,'Goblin',2,'Beastman',40,100,100,4,4,3,4,4,4,5,3,3,3,3,0.0,3,1);
INSERT INTO `mob_species_system` VALUES (60,'Crab',60,'Crab',3,'Aquan',40,100,100,4,4,3,4,4,4,5,3,3,3,3,0.0,1,1);
INSERT INTO `mob_species_system` VALUES (70,'LocalSpecies',70,'LocalSpecies',1,'Amorph',40,100,100,4,4,3,4,4,4,5,3,3,3,3,0.0,0,1);
