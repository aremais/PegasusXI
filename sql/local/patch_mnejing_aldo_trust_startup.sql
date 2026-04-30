-- =============================================================================
-- LOCAL / SERVER-OWNED - safe live DB repair for trust startup warnings.
--
-- Fixes:
--   * "Could not look up trust data for id: 926" (Mnejing)
--   * Aldo trust skill_list_id=1045 loading with empty tp_skills
--
-- Usage:
--   mysql -u USER -p DATABASE < sql/local/patch_mnejing_aldo_trust_startup.sql
-- =============================================================================

SET NAMES utf8mb4;

-- Trust spells. Trust loading expects poolid = spellid + 5000.
INSERT IGNORE INTO `spell_list` VALUES
(926,'mnejing',0x01010101010101010101010101010101010101010101,8,0,7,0,1,0,0,2000,240000,0,0,939,1500,0,0,1.00,0,0,0,0,0,NULL),
(930,'aldo',0x01010101010101010101010101010101010101010101,8,0,7,0,1,0,0,2000,240000,0,0,939,1500,0,0,1.00,0,0,0,0,0,NULL);

-- Trust pools and their required family/resistance/skill-list references.
INSERT INTO `mob_pools` VALUES
(5926,'mnejing','Mnejing',364,0x0000D60B00000000000000000000000000000000,7,1,3,240,100,0,0,0,0,0,0,32,0,3,0,0,0,0,0,1041,1041,1,8),
(5930,'aldo','Aldo',149,0x0000DA0B00000000000000000000000000000000,6,0,1,240,100,0,0,0,0,0,0,32,0,3,0,0,0,0,0,1045,149,0,15)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `packet_name` = VALUES(`packet_name`),
    `familyid` = VALUES(`familyid`),
    `modelid` = VALUES(`modelid`),
    `mJob` = VALUES(`mJob`),
    `sJob` = VALUES(`sJob`),
    `cmbSkill` = VALUES(`cmbSkill`),
    `cmbDelay` = VALUES(`cmbDelay`),
    `cmbDmgMult` = VALUES(`cmbDmgMult`),
    `skill_list_id` = VALUES(`skill_list_id`),
    `resist_id` = VALUES(`resist_id`),
    `modelSize` = VALUES(`modelSize`),
    `modelHitboxSize` = VALUES(`modelHitboxSize`);

-- TP skills required by the trust AI. Player WS ids must exist in weapon_skills;
-- Mnejing's automaton moves must exist in mob_skills.
INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
('TRUST_Mnejing', 1041, 1940),
('TRUST_Mnejing', 1041, 1941),
('TRUST_Aldo', 1045, 16),
('TRUST_Aldo', 1045, 23),
('TRUST_Aldo', 1045, 25);
