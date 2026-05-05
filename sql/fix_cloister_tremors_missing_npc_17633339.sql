-- Cloister of Tremors (209): spawn missing npcid 17633339 (targid 59)
--
-- This slot is present only as a commented NOT_CAPTURED row in npc_list. The
-- retail client still polls it with 0x016 CHARREQ, producing repeated map logs:
--   Could not look up entity <59, 17633339> in zone <Cloister_of_Tremors (209)>
--
-- Run once against your database, then restart the map server (or reload zone 209).
-- Safe to re-run: INSERT IGNORE skips duplicates.

INSERT IGNORE INTO `npc_list` VALUES (17633339,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
