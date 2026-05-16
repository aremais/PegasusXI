-- FeiYin (204): npcid 17613241 (targid 441) — invisible retail cutscene actor next to Rukususu (17613240).
-- Windurst M8-2 (CS 22 at Cermet door _no4) makes the client poll this slot via 0x016 CHARREQ.
-- Missing row → CHARREQ spam and cutscene soft-lock:
--   Could not look up entity <441, 17613241> in zone <FeiYin (204)>
--
-- New installs: row is in sql/npc_list.sql. Use this script only to patch an older database.
-- Run once; restart map server or reload zone 204 afterward.

INSERT IGNORE INTO `npc_list` VALUES (17613241,'blank','',0,0.000,0.000,0.000,0,40,40,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
