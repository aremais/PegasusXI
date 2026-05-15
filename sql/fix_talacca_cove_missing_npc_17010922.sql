-- Talacca Cove (57): spawn missing npcid 17010922 (targid 234)
--
-- This slot was present only as a commented NOT_CAPTURED row in npc_list. The
-- retail client still polls it with 0x016 CHARREQ, producing repeated map logs:
--   Could not look up entity <234, 17010922> in zone <Talacca_Cove (57)>
--
-- Run once against your database, then restart the map server (or reload zone 57).
-- Safe to re-run: INSERT IGNORE skips duplicates.

INSERT IGNORE INTO `npc_list` VALUES (17010922,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
