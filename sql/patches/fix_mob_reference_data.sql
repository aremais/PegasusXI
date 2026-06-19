-- Align mob_groups.dropid and mob_pools.spellList with valid reference data.
-- Fixes map startup errors for empty droplists and missing mob spell lists.
-- Safe to re-run.

-- Lesser Arimaspi droplist (from fix_missing_mob_droplists.sql)
DELETE FROM `mob_droplist` WHERE `dropId` = 1508;
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1633,30); -- Handful Of Clot Plasma (3.0%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,4377,23); -- Slice Of Coeurl Meat (2.3%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1634,22); -- Rhodonite (2.2%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,887,22);  -- Coral Fragment (2.2%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,4272,22); -- Slice Of Dragon Meat (2.2%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,5152,21); -- Slice Of Buffalo Meat (2.1%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1997,21); -- Square Of Sailcloth (2.1%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1294,19); -- Spool Of Arachne Thread (1.9%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,830,18);  -- Square Of Rainbow Cloth (1.8%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,645,17);  -- Chunk Of Darksteel Ore (1.7%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1740,17); -- Iolite (1.7%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,823,17);  -- Spool Of Gold Thread (1.7%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,942,17);  -- Philosophers Stone (1.7%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1133,16); -- Vial Of Dragon Blood (1.6%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1311,16); -- Piece Of Oxblood (1.6%)
INSERT INTO `mob_droplist` VALUES (1508,0,0,1000,1829,15); -- Square Of Red Grass Cloth (1.5%)

-- Inner Horutoto Ruins: spawn-slot mobs must not use SPAWNTYPE_SCRIPTED (0x80).
UPDATE `mob_groups` SET `respawntime` = 330, `spawntype` = 1
WHERE `zoneid` = 192 AND `name` IN ('Magicked_Bones_club', 'Magicked_Bones_dagger');

UPDATE `mob_groups` SET `dropid` = 2930 WHERE `zoneid` = 4 AND `name` = 'Locus_Ghost_Crab'; -- was 2931
UPDATE `mob_groups` SET `dropid` = 181 WHERE `zoneid` = 77 AND `name` = 'Smothered_Schmidt'; -- was 2277
UPDATE `mob_groups` SET `dropid` = 1881 WHERE `zoneid` = 84 AND `name` = 'Orcish_Brawler'; -- was 1878
UPDATE `mob_groups` SET `dropid` = 123 WHERE `zoneid` = 114 AND `name` = 'Antican_Faber'; -- was 122
UPDATE `mob_groups` SET `dropid` = 2770 WHERE `zoneid` = 119 AND `name` = 'Yagudo_Votary'; -- was 2774
UPDATE `mob_groups` SET `dropid` = 964 WHERE `zoneid` = 126 AND `name` = 'Giant_Ranger'; -- was 971
UPDATE `mob_groups` SET `dropid` = 2651 WHERE `zoneid` = 126 AND `name` = 'Wight_blm'; -- was 2652
UPDATE `mob_groups` SET `dropid` = 2651 WHERE `zoneid` = 126 AND `name` = 'Wight_war'; -- was 2652
UPDATE `mob_groups` SET `dropid` = 2005 WHERE `zoneid` = 155 AND `name` = 'Platinum_Quadav'; -- was 669
UPDATE `mob_groups` SET `dropid` = 1082 WHERE `zoneid` = 166 AND `name` = 'Goblin_Gambler'; -- was 1079
UPDATE `mob_groups` SET `dropid` = 0 WHERE `zoneid` = 168 AND `name` = 'Centurio_V-III'; -- was 12000
UPDATE `mob_groups` SET `dropid` = 0 WHERE `zoneid` = 191 AND `name` = 'Goblin_Conjurer'; -- was 3187
UPDATE `mob_groups` SET `dropid` = 0 WHERE `zoneid` = 195 AND `name` = 'Tomb_Wolf'; -- was 2887

UPDATE `mob_pools` SET `spellList` = 32 WHERE `poolid` = 385; -- Beelzebub: was 74
UPDATE `mob_pools` SET `spellList` = 32 WHERE `poolid` = 425; -- Bitoso: was 62
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 766; -- Colo-colo: was 59
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 773; -- Compound_Eyes: was 67
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1101; -- Dragonian_Minstrel: was 76
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1130; -- Duke_Amduscias: was 73
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1149; -- Dvorovoi: was 69
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1441; -- Furies: was 60
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1602; -- Gilagoge_Tlugvi: was 545
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1748; -- Gola_Tlugvi: was 544
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 1910; -- Heavy_Metal_Crab: was 58
UPDATE `mob_pools` SET `spellList` = 32 WHERE `poolid` = 1923; -- Helltail_Harry: was 70
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 2011; -- Huntfly: was 63
UPDATE `mob_pools` SET `spellList` = 32 WHERE `poolid` = 2467; -- Macan_Gadangan: was 72
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 2468; -- Macha: was 61
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 2646; -- Metsanneitsyt: was 64
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 2822; -- Nenaunir: was 65
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 2990; -- Opo-opo_Monarch: was 68
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3116; -- Pepper: was 142
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3132; -- Phoedme: was 142
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3214; -- Prune: was 142
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3429; -- Sabotender_Campeon: was 75
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3693; -- Sobbing_Eyes: was 66
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 3847; -- Tartaruga_Gigante: was 77
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 4077; -- Ulagohvsdi_Tlugvi: was 543
UPDATE `mob_pools` SET `spellList` = 0 WHERE `poolid` = 4883; -- Sarcopsylla: was 505
