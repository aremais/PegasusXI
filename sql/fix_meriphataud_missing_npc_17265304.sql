-- Meriphataud Mountains (119): npcid 17265304-17265308 (targid 664-668) were
-- only present as commented NOT_CAPTURED rows.
--
-- The Holy Crest cutscene after trading the Wyvern Egg to qm1 (CS 56) makes the
-- client poll these actors. Missing rows -> CHARREQ spam and a possible soft-lock:
--   Could not look up entity <664, 17265304> in zone <Meriphataud_Mountains (119)>
--   Could not look up entity <665, 17265305> in zone <Meriphataud_Mountains (119)>
--
-- Run once; restart map or reload zone 119 afterward.

INSERT IGNORE INTO `npc_list` VALUES (17265304,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17265305,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17265306,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17265307,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17265308,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
