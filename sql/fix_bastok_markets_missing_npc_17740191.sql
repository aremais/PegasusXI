-- Bastok Markets (235): npc_list ids 17740191–17740195 (targids 415–419) and 17740197 (targid 421).
--
-- npc_list jumped from Horro (17740190 / targid 414) to Achieve_Master (17740196 / targid 420),
-- and from Achieve_Master to 17740198 (targid 422) without 17740197. The retail client sends
-- 0x016 CHARREQ for those targids; with no row the map logs:
--   Could not look up entity <415, 17740191> in zone <Bastok_Markets (235)>
-- (and similar), often every ~2s until the slot exists.
--
-- If your DB predates npc_list.sql including these rows, run once:
--   mysql ... < sql/fix_bastok_markets_missing_npc_17740191.sql
-- Then restart map (or reload zone 235).

INSERT IGNORE INTO `npc_list` VALUES (17740191,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740192,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740193,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740194,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740195,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740197,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
