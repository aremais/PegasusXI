-- Ship bound for Selbina *Pirates* (zone 227): mobids must satisfy ((mobid >> 12) & 0xFFF) = 227.
-- Older dumps used IDs that decode as zone 225 (Windurst–Jeuno airship). Add 8192 per row
-- (increments zone nibble 225 -> 227) for that block only.
-- Safe to re-run: rows already at 177152xx no longer match the WHERE and are skipped.

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` + 8192
WHERE `mobid` >= 17707009 AND `mobid` <= 17707026;
