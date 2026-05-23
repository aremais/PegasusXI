-- Fix Strange Happenings TVR mobs: mob_groups pointed at missing poolids 7358-7361.
UPDATE `mob_groups` SET `poolid` = 7087 WHERE `zoneid` = 72  AND `groupid` = 16; -- Alexander
UPDATE `mob_groups` SET `poolid` = 2265 WHERE `zoneid` = 130 AND `groupid` = 22; -- Kirin
UPDATE `mob_groups` SET `poolid` = 2266 WHERE `zoneid` = 130 AND `groupid` = 23; -- Kirin's Avatar
UPDATE `mob_groups` SET `poolid` = 1280 WHERE `zoneid` = 153 AND `groupid` = 43; -- Fafnir
