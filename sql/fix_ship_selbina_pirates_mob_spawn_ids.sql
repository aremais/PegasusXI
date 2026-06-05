-- Ship bound for Selbina *Pirates* (zone 227): mobids must satisfy ((mobid >> 12) & 0xFFF) = 227.
-- Rows at 17715201-17715218 decode as zone 229, so mob_groups.zoneid = 227 never matches and NO mobs load.
-- Correct range is 17707009-17707026 (same as a clean mob_spawn_points dump).
--
-- Re-runnable after a partial import: if both a wrong id (17715201-17715218) and its target
-- (wrong-8192) exist, DELETE the stale wrong row, then UPDATE whatever is still in the wrong range.
-- Mobname filter avoids touching Throne Room [V] (zone 229) rows at 17715201-17715206 in a clean dump.

-- Drop orphan wrong-range rows when the corrected id is already present (avoids ERROR 1062 duplicate primary key).
DELETE t1
    FROM `mob_spawn_points` AS t1
    INNER JOIN `mob_spawn_points` AS t2 ON t2.`mobid` = t1.`mobid` - 8192
WHERE
    t1.`mobid` >= 17715201
    AND t1.`mobid` <= 17715218
    AND t1.`mobname` IN (
        'Sea_Pugil',
        'Ocean_Crab',
        'Ocean_Pugil',
        'Pirate_Pugil',
        'Sea_Monk',
        'Sea_Crab',
        'Phantom',
        'Crossbones',
        'Ship_Wight',
        'Blackbeard',
        'Enagakure'
    );

UPDATE `mob_spawn_points`
SET `mobid` = `mobid` - 8192
WHERE
    `mobid` >= 17715201
    AND `mobid` <= 17715218
    AND `mobname` IN (
        'Sea_Pugil',
        'Ocean_Crab',
        'Ocean_Pugil',
        'Pirate_Pugil',
        'Sea_Monk',
        'Sea_Crab',
        'Phantom',
        'Crossbones',
        'Ship_Wight',
        'Blackbeard',
        'Enagakure'
    );
