-- One-time fix: Spire of Vahzl (zone 23) spawns were stored with mobids that decode as zone 22.
-- GetFirstID / PopulateIDLookups use ((mobid >> 12) & 0xFFF) = zoneid, so zone 23 failed for IDs.lua.
-- Adds 4096 per row (increments zone nibble 22 -> 23) for the Spire_of_Vahzl block only.
--
-- Re-runnable after a partial import: if both an old id (16871425-16871571) and its target
-- (old+4096) exist, DELETE the stale old row, then UPDATE whatever is still in the old range.

-- Drop orphan old rows when the corrected id is already present (avoids ERROR 1062 duplicate primary key).
DELETE t1
    FROM `mob_spawn_points` AS t1
    INNER JOIN `mob_spawn_points` AS t2 ON t2.`mobid` = t1.`mobid` + 4096
WHERE
    t1.`mobid` >= 16871425
    AND t1.`mobid` <= 16871571;

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` + 4096
WHERE `mobid` >= 16871425 AND `mobid` <= 16871571;
