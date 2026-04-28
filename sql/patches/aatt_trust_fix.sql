-- AATT Trust DB fixes

UPDATE mob_pools
SET cmbSkill = 7
WHERE poolid = 5995;

UPDATE mob_spell_lists
SET min_level = 1
WHERE spell_list_id = 408
AND spell_id IN (273, 274);
