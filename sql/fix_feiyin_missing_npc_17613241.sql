-- FeiYin (204): npcid 17613241 (targid 441) was only present as a commented NOT_CAPTURED row.
-- Windurst M8-2 cutscene (CS 22 at Cermet door _no4) makes the client poll this actor.
-- Missing row → CHARREQ spam and possible cutscene soft-lock:
--   Could not look up entity <441, 17613241> in zone <FeiYin (204)>
--
-- Run once; restart map or reload zone 204 afterward.

INSERT IGNORE INTO `npc_list` VALUES (17613241,'blank','',0,0.000,0.000,0.000,0,40,40,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
