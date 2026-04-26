-- =============================================================================
-- LOCAL / SERVER-OWNED — not dependent on upstream repo dumps being applied.
-- Ensures Amchuchu (trust pool 5969, spell 969) can load TP weapon skills.
-- Safe to re-run: INSERT IGNORE + conditional UPDATE.
--
-- Usage (example):
--   mysql -u USER -p DATABASE < sql/local/patch_amchuchu_trust_weapon_skills.sql
-- =============================================================================

SET NAMES utf8mb4;

-- Pool 5969 = trust spell 969 + 5000 (LandSandBoat trust lookup convention)
UPDATE mob_pools
SET skill_list_id = 1084
WHERE poolid = 5969;

-- Skill list 1084: Great Sword WS for trust AI (TryTrustSkill / tp_skills)
INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
('TRUST_Amchuchu', 1084, 49),
('TRUST_Amchuchu', 1084, 54),
('TRUST_Amchuchu', 1084, 61);

-- Core weapon skill rows (if your DB was trimmed / partial import)
INSERT IGNORE INTO `weapon_skills` VALUES
(49,'power_slash',0x02000000000002020000000000000000000000000002,4,30,0,107,2000,3,1,0,1,0,0,0,0),
(54,'sickle_moon',0x00000000000001010000000000000000000000000001,4,200,0,112,2000,3,1,0,4,8,0,1,0),
(61,'dimidiation',0x00000000000000000000000000000000000000000001,4,0,0,119,2000,3,1,0,13,12,0,1,49);
