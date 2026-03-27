-- One-time fix: Spire of Vahzl (zone 23) spawns were stored with mobids that decode as zone 22.
-- GetFirstID / PopulateIDLookups use ((mobid >> 12) & 0xFFF) = zoneid, so zone 23 failed for IDs.lua.
-- Adds 4096 per row (increments zone nibble 22 -> 23) for the Spire_of_Vahzl block only.
-- Safe to re-run: rows already at 168755xx no longer match the WHERE and are skipped.

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` + 4096
WHERE `mobid` >= 16871425 AND `mobid` <= 16871571;
