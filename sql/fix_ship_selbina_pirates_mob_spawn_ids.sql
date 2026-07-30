-- Ship bound for Selbina *Pirates* (zone 227): mobids must satisfy ((mobid >> 12) & 0xFFF) = 227.
-- Rows at 17715201-17715218 decode as zone 229, so mob_groups.zoneid = 227 never matches and NO mobs load.
-- Correct range is 17707009-17707026 (same as a clean mob_spawn_points dump).
--
-- Idempotent:
-- 1) If a correct-range row already exists for the same offset, drop the bad-range duplicate.
-- 2) Rename any remaining bad-range rows into the correct range.

DELETE w
FROM `mob_spawn_points` AS w
INNER JOIN `mob_spawn_points` AS c ON c.`mobid` = w.`mobid` - 8192
WHERE w.`mobid` >= 17715201 AND w.`mobid` <= 17715218;

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` - 8192
WHERE `mobid` >= 17715201 AND `mobid` <= 17715218;
