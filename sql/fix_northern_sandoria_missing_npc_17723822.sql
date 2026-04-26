-- Northern San d'Oria (231): spawn missing npcid 17723822 (targid 430)
--
-- The retail client still polls this CHARREQ slot. Without a backing npc_list row,
-- map logs repeated debug lines:
--   Could not look up entity <430, 17723822> in zone <Northern_San_dOria (231)>
--
-- Run once against your database, then restart the map server (or reload the zone).
INSERT IGNORE INTO `npc_list`
VALUES (17723822,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,1);
