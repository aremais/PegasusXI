-- Repair data for mobs reported by luautils::GetMobByID as missing.
--
-- The Fomor's Bats rows were present in mob_spawn_points, but their mob_groups
-- referenced non-existent mob_pools rows, so the loader skipped them. The
-- Riverne-Site_B01 rows are included here to repair existing databases that are
-- missing or have stale copies of those spawn/group rows.

INSERT INTO `mob_groups` VALUES
    (16,1394,28,'Fomors_Bats',0,128,0,0,0,0,NULL),
    (10,1394,51,'Fomors_Bats',0,128,0,0,0,0,NULL),
    (9,1394,52,'Fomors_Bats',0,128,0,0,0,0,NULL),
    (10,71,29,'Air_Elemental',300,4,38,0,0,0,NULL),
    (22,4507,29,'Ziryu',0,128,0,2500,15000,0,NULL)
ON DUPLICATE KEY UPDATE
    `poolid` = VALUES(`poolid`),
    `name` = VALUES(`name`),
    `respawntime` = VALUES(`respawntime`),
    `spawntype` = VALUES(`spawntype`),
    `dropid` = VALUES(`dropid`),
    `HP` = VALUES(`HP`),
    `MP` = VALUES(`MP`),
    `allegiance` = VALUES(`allegiance`),
    `content_tag` = VALUES(`content_tag`);

INSERT INTO `mob_spawn_points` VALUES
    (16891960,0,'Fomors_Bats','Fomor''s Bats',16,49,51,1.000,1.000,1.000,117),
    (16892007,0,'Fomors_Bats','Fomor''s Bats',16,49,51,1.000,1.000,1.000,196),
    (16892011,0,'Fomors_Bats','Fomor''s Bats',16,49,51,1.000,1.000,1.000,32),
    (16896134,0,'Air_Elemental','Air Elemental',10,57,64,-586.808,1.079,689.897,193),
    (16896165,0,'Ziryu','Ziryu',22,74,76,-693.144,0.284,816.515,0),
    (16990224,0,'Fomors_Bats','Fomor''s Bats',9,58,60,1.000,1.000,1.000,0),
    (16990233,0,'Fomors_Bats','Fomor''s Bats',9,58,60,1.000,1.000,1.000,0),
    (16990248,0,'Fomors_Bats','Fomor''s Bats',9,58,60,1.000,1.000,1.000,0),
    -- Ro'Maeve: Bastok 7-1 Mokkurkalfi (QM pop; required for GetMobByID)
    (17276929,0,'Mokkurkalfi','Mokkurkalfi',1,68,70,104.729,-4.143,-115.265,215),
    (17276930,0,'Mokkurkalfi','Mokkurkalfi',1,68,70,101.918,-4.000,-115.265,215)
ON DUPLICATE KEY UPDATE
    `spawnslotid` = VALUES(`spawnslotid`),
    `mobname` = VALUES(`mobname`),
    `polutils_name` = VALUES(`polutils_name`),
    `groupid` = VALUES(`groupid`),
    `minLevel` = VALUES(`minLevel`),
    `maxLevel` = VALUES(`maxLevel`),
    `pos_x` = VALUES(`pos_x`),
    `pos_y` = VALUES(`pos_y`),
    `pos_z` = VALUES(`pos_z`),
    `pos_rot` = VALUES(`pos_rot`);

-- Bastok 7-1: ensure group row exists if mob_groups was imported without Ro'Maeve NMs
INSERT INTO `mob_groups` VALUES
    (1,2717,122,'Mokkurkalfi',0,128,0,0,0,0,NULL)
ON DUPLICATE KEY UPDATE
    `poolid` = VALUES(`poolid`),
    `name` = VALUES(`name`),
    `respawntime` = VALUES(`respawntime`),
    `spawntype` = VALUES(`spawntype`),
    `dropid` = VALUES(`dropid`),
    `HP` = VALUES(`HP`),
    `MP` = VALUES(`MP`),
    `allegiance` = VALUES(`allegiance`),
    `content_tag` = VALUES(`content_tag`);
