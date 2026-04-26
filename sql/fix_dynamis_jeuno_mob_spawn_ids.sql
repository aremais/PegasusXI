-- Dynamis-Jeuno (zone 188): mob load and GetFirstID both require
--   ((mobid >> 12) & 0xFFF) = 188
-- (see zoneutils::LoadMOBList join and luautils::PopulateIDLookups).
--
-- Symptoms when this is wrong:
--   - Empty or nearly empty zone; Goblin time-extension statues never appear on entry.
--   - Lottery NMs (odious cup/die/mask/grenade) never replace Vanguard placeholders: phOnDespawn
--     needs the NM entity loaded; wrong mobid = no entity = no pops, so boss trade items cannot
--     be obtained.
--
-- If rows are off by one block (e.g. decode as zone 187), no mobs appear in the zone and
-- GetFirstID returns nil for lottery NMs — phOnDespawn never runs. scripts/zones/Dynamis-Jeuno/IDs.lua
-- uses numeric fallbacks for NM ids; the DB must still list correct mobids or entities are never created.
--
-- Verify: every row in the Jeuno block should report zone_from_id = 188.

SELECT `mobid`, `mobname`, ((`mobid` >> 12) & 0xFFF) AS `zone_from_id`
FROM `mob_spawn_points`
WHERE `mobid` BETWEEN 17547265 AND 17547499
ORDER BY `mobid`;

-- If any row shows zone_from_id <> 188, re-import those rows from sql/mob_spawn_points.sql
-- or adjust mobid by +4096 only for rows that are actually Dynamis-Jeuno spawns (do not
-- change Dynamis-Windurst rows: 17543169-17543469 decode as zone 187 by design).
--
-- Example: if a Jeuno row incorrectly shows zone_from_id = 187, it is often 4096 too low:
--   UPDATE `mob_spawn_points` SET `mobid` = `mobid` + 4096 WHERE `mobid` = <wrong_id>;
-- Confirm the new id matches repo sql/mob_spawn_points.sql for that spawn before committing.
