-- Fix missing/empty mob droplist IDs seen during map startup.
-- Source data from FFXIDB tracking for the affected mobs.

DELETE FROM `mob_droplist` WHERE `dropId` IN (195, 1502, 1508);

-- ZoneID: 187 - Avatar Icon
INSERT INTO `mob_droplist` VALUES (195,0,0,1000,1474,161); -- Infinity Core (16.1%)
INSERT INTO `mob_droplist` VALUES (195,0,0,1000,1470,65);  -- Sparkling Stone (6.5%)
INSERT INTO `mob_droplist` VALUES (195,0,0,1000,749,32);   -- Mythril Beastcoin (3.2%)
INSERT INTO `mob_droplist` VALUES (195,0,0,1000,1449,32);  -- Tukuku Whiteshell (3.2%)

-- ZoneID: 132 - La Theine Liege
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,11562,340); -- Sharpeye Mantle (34.0%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,1633,35);   -- Handful Of Clot Plasma (3.5%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,4377,28);   -- Slice Of Coeurl Meat (2.8%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,1446,27);   -- Lacquer Tree Log (2.7%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,1997,26);   -- Square Of Sailcloth (2.6%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,5152,26);   -- Slice Of Buffalo Meat (2.6%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,4272,25);   -- Slice Of Dragon Meat (2.5%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,887,25);    -- Coral Fragment (2.5%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,2532,23);   -- Teak Log (2.3%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,2315,21);   -- Clump Of Karakul Wool (2.1%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,645,21);    -- Chunk Of Darksteel Ore (2.1%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,702,21);    -- Ebony Log (2.1%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,830,21);    -- Square Of Rainbow Cloth (2.1%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,823,21);    -- Spool Of Gold Thread (2.1%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,1769,20);   -- Square Of Galateia (2.0%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,722,20);    -- Divine Log (2.0%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,1415,19);   -- Pot Of Urushi (1.9%)
INSERT INTO `mob_droplist` VALUES (1502,0,0,1000,846,4);     -- Insect Wing (0.4%)

-- ZoneID: 15 - Lesser Arimaspi
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

UPDATE `mob_groups` SET `dropid` = 1508 WHERE `zoneid` = 15 AND `name` = 'Lesser_Arimaspi';
UPDATE `mob_groups` SET `dropid` = 1502 WHERE `zoneid` = 132 AND `name` = 'La_Theine_Liege';
UPDATE `mob_groups` SET `dropid` = 195 WHERE `zoneid` = 187 AND `name` = 'Avatar_Icon';
