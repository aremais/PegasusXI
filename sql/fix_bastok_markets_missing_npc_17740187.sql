-- Bastok Markets (235): enable npc_list id 17740187 (targid 411).
--
-- The row existed only as `-- NC:` in npc_list; the retail client sends 0x016 CHARREQ
-- for targid 411, i.e. npc id ((4096 + 235) << 12) + 411 = 17740187. With no entity,
-- the map server logs:
--   Could not look up entity <411, 17740187> in zone <Bastok_Markets (235)>
-- and the client can blackscreen waiting for the spawn packet.
--
-- If your DB was imported before npc_list.sql included this row, run once:
--   mysql ... < sql/fix_bastok_markets_missing_npc_17740187.sql
-- Then restart map (or reload zone 235).

INSERT IGNORE INTO `npc_list` VALUES (17740187,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
