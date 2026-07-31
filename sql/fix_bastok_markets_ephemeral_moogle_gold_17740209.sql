-- Bastok Markets (zone 235): Goldsmiths' Guild Ephemeral Moogle at retail targid 433 (npcid 17740209).
--
-- The client issues 0x016 CHARREQ for targid 433, i.e. npcid ((4096 + 235) << 12) + 433 = 17740209.
-- If that row is missing, commented out, or a blank NPC, you get log spam and/or wrong target ("NPC") / soft lock.
-- The Ephemeral must use internal script name Ephemeral_Moogle_Gold (scripts/zones/Bastok_Markets/npcs/Ephemeral_Moogle_Gold.lua).
-- content_tag must be NULL (or SOA enabled with RESTRICT_CONTENT off) or LoadNPCList skips the row.
--
-- If your DB predates npc_list.sql fixes for 17740204–17740211 / 17740209, run once:
--   mysql ... xidb < sql/fix_bastok_markets_ephemeral_moogle_gold_17740209.sql
-- Then restart the map server (or reload zone 235).

-- Retail targid gap placeholders (same as npc_list.sql).
INSERT IGNORE INTO `npc_list` VALUES (17740204,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740205,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740206,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740207,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740208,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740210,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);
INSERT IGNORE INTO `npc_list` VALUES (17740211,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);

-- Ephemeral at client slot 433; overwrites any existing row for this npcid.
INSERT INTO `npc_list` VALUES (17740209,'Ephemeral_Moogle_Gold','Ephemeral Moogle',221,-219.820,-6.820,-63.250,14,50,50,0,0,128,0,3,0x0000520000000000000000000000000000000000,0,NULL,1)
ON DUPLICATE KEY UPDATE
  `name` = 'Ephemeral_Moogle_Gold',
  `polutils_name` = 'Ephemeral Moogle',
  `pos_rot` = 221,
  `pos_x` = -219.820,
  `pos_y` = -6.820,
  `pos_z` = -63.250,
  `flag` = 14,
  `speed` = 50,
  `speedsub` = 50,
  `animation` = 0,
  `animationsub` = 0,
  `namevis` = 128,
  `status` = 0,
  `entityFlags` = 3,
  `look` = 0x0000520000000000000000000000000000000000,
  `name_prefix` = 0,
  `content_tag` = NULL,
  `widescan` = 1;

-- Former Ephemeral slot (targid 448); clear so only one guild Ephemeral exists at retail coords.
UPDATE `npc_list` SET
  `name` = 'blank',
  `polutils_name` = '',
  `pos_rot` = 0,
  `pos_x` = 0.000,
  `pos_y` = 0.000,
  `pos_z` = 0.000,
  `flag` = 0,
  `speed` = 50,
  `speedsub` = 50,
  `animation` = 0,
  `animationsub` = 0,
  `namevis` = 0,
  `status` = 2,
  `entityFlags` = 3,
  `look` = 0x0000320000000000000000000000000000000000,
  `name_prefix` = 0,
  `content_tag` = NULL,
  `widescan` = 0
WHERE `npcid` = 17740224;
