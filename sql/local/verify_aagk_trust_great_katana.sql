-- =============================================================================
-- LOCAL verification - run after patch + map SQL load.
-- Expect: AAGK pool row with cmbSkill=10 and skill_list_id=1111.
-- =============================================================================

SELECT `poolid`, `name`, `mJob`, `sJob`, `cmbSkill`, `cmbDelay`, `skill_list_id`
FROM `mob_pools`
WHERE `poolid` = 5996;