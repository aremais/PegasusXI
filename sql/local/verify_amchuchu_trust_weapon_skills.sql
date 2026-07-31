-- =============================================================================
-- LOCAL verification — run after patch + map SQL load.
-- Expect: pool row with skill_list_id=1084; 3 mob_skill_lists rows; 3 weapon_skills rows.
-- =============================================================================

SELECT 'mob_pools 5969' AS step_name, poolid, skill_list_id, spellList
FROM mob_pools
WHERE poolid = 5969;

SELECT 'mob_skill_lists 1084' AS step_name, skill_list_id, mob_skill_id
FROM mob_skill_lists
WHERE skill_list_id = 1084 AND mob_skill_id IN (49, 54, 61)
ORDER BY mob_skill_id;

SELECT 'weapon_skills' AS step_name, weaponskillid, name
FROM weapon_skills
WHERE weaponskillid IN (49, 54, 61)
ORDER BY weaponskillid;
