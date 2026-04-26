-- Ship bound for Selbina *Pirates* (zone 227): mobids must satisfy ((mobid >> 12) & 0xFFF) = 227.
-- Rows at 17715201-17715218 decode as zone 229, so mob_groups.zoneid = 227 never matches and NO mobs load.
-- Correct range is 17707009-17707026 (same as a clean mob_spawn_points dump).
-- Safe to re-run: rows already corrected no longer match the WHERE.

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` - 8192
WHERE `mobid` >= 17715201 AND `mobid` <= 17715218;
