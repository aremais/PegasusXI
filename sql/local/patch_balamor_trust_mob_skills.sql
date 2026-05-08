-- =============================================================================
-- LOCAL / SERVER-OWNED - not dependent on upstream repo dumps being reapplied.
-- Ensures Balamor (trust pool 5983, spell 983) can load TP mob skills.
-- Safe to re-run: INSERT IGNORE + targeted UPDATE.
--
-- Usage (example):
--   mysql -u USER -p DATABASE < sql/local/patch_balamor_trust_mob_skills.sql
-- Restart the map server after applying so LoadMobSkillsList reloads the rows.
-- =============================================================================

SET NAMES utf8mb4;

-- Pool 5983 = trust spell 983 + 5000 (LandSandBoat trust lookup convention)
UPDATE `mob_pools`
SET `skill_list_id` = 1098
WHERE `poolid` = 5983 AND `name` = 'balamor';

-- Skill list 1098: Balamor special moves for trust AI (TryTrustSkill / tp_skills)
INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
('TRUST_Balamor', 1098, 3617),
('TRUST_Balamor', 1098, 3618),
('TRUST_Balamor', 1098, 3619),
('TRUST_Balamor', 1098, 3620);

-- Core mob skill rows (if your DB was trimmed / partial import)
INSERT IGNORE INTO `mob_skills`
(`mob_skill_id`, `mob_anim_id`, `mob_skill_name`, `mob_skill_aoe`, `mob_skill_aoe_radius`, `mob_skill_distance`, `mob_anim_time`, `mob_prepare_time`, `mob_valid_targets`, `mob_skill_flag`, `mob_skill_param`, `knockback`, `primary_sc`, `secondary_sc`, `tertiary_sc`) VALUES
(3617, 2347, 'feast_of_arrows',      0, 0.0, 7.0, 2000, 1500, 4, 0, 0, 0, 0, 0, 0),
(3618, 2349, 'regurgitated_swarm',   0, 0.0, 7.0, 2000, 1500, 4, 0, 0, 0, 0, 0, 0),
(3619, 2350, 'setting_the_stage',    0, 0.0, 7.0, 2000, 1500, 4, 0, 0, 0, 0, 0, 0),
(3620, 2351, 'last_laugh',           0, 0.0, 7.0, 2000, 1500, 4, 0, 0, 0, 0, 0, 0);
