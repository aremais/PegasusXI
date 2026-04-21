-- Fix AAGK trust combat skill / weapon type to Great Katana
UPDATE `mob_pools`
SET `cmbSkill` = 10
WHERE `poolid` = 5996;