-- Southern San d'Oria (zone 230): Repairer Moogle at retail targid 738 (npcid 17720034).
--
-- Fixes:
--   1. Missing targid 734 placeholder (17720030) — client CHARREQ polls this slot.
--   2. Repairer Moogle row + script name RepairerMoogle (scripts/zones/Southern_San_dOria/npcs/RepairerMoogle.lua).
--   3. entityFlags/name_prefix aligned with other city moogles (Ephemeral pattern).
--
-- Run once, then restart the map server (or reload zone 230):
--   Get-Content sql\fix_southern_sandoria_repairer_moogle_17720034.sql -Raw | mysql --protocol=TCP -h 127.0.0.1 -P 3306 -u root -p xidb

INSERT IGNORE INTO `npc_list` VALUES (17720030,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,0);

INSERT INTO `npc_list` VALUES (17720034,'RepairerMoogle','Repairer Moogle',216,-86.850,1.000,-54.250,15,50,50,0,0,0,0,3,0x0000520000000000000000000000000000000000,0,'SOA',1)
ON DUPLICATE KEY UPDATE
  `name` = 'RepairerMoogle',
  `polutils_name` = 'Repairer Moogle',
  `pos_rot` = 216,
  `pos_x` = -86.850,
  `pos_y` = 1.000,
  `pos_z` = -54.250,
  `flag` = 15,
  `speed` = 50,
  `speedsub` = 50,
  `animation` = 0,
  `animationsub` = 0,
  `namevis` = 0,
  `status` = 0,
  `entityFlags` = 3,
  `look` = 0x0000520000000000000000000000000000000000,
  `name_prefix` = 0,
  `content_tag` = 'SOA',
  `widescan` = 1;
