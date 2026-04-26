-- Dynamis - Beaucedine / Dynamis-Beaucedine Glacier (zone 134): mob load and GetFirstID require
--   ((mobid >> 12) & 0xFFF) = 134
-- (see zoneutils::LoadMOBList join and luautils::PopulateIDLookups).
--
-- Repo block: sql/mob_spawn_points.sql between the Beaucedine (134) and Xarcabard (135) section
-- headers (mobids approximately 17326081-17326790). If imports drift, use scripts in
-- scripts/zones/Dynamis-Beaucedine/IDs.lua numeric fallbacks and fix rows here.

SELECT `mobid`, `mobname`, ((`mobid` >> 12) & 0xFFF) AS `zone_from_id`
FROM `mob_spawn_points`
WHERE `mobid` BETWEEN 17326081 AND 17326790
ORDER BY `mobid`;

-- Expect every row: zone_from_id = 134. If not, re-import from sql/mob_spawn_points.sql or correct
-- mobids so they match zone 134 encoding (same class of issue as sql/fix_spire_of_vahzl_mob_spawn_ids.sql).
