-- LandSandBoat base branch uses varchar(32) for mob_pools.name (internal pool key).
-- packet_name stays varchar(24); client display is further capped at 16 chars in packets.
ALTER TABLE `mob_pools` MODIFY `name` varchar(32) DEFAULT NULL;

-- Restore pool keys truncated during the prior varchar(24) import.
UPDATE `mob_pools` SET `name` = 'Harnessed_Smilodon_Ranguemont' WHERE `poolid` = 6042 AND `name` = 'Harnessed_Smilodon_Rangu';
UPDATE `mob_pools` SET `name` = 'Harnessed_Smilodon_Beaucedine' WHERE `poolid` = 6047 AND `name` = 'Harnessed_Smilodon_Beauc';
UPDATE `mob_pools` SET `name` = 'Kirins_Avatar_Strange_Happenings' WHERE `poolid` = 7360 AND `name` = 'Kirins_Avatar_Strange_Ha';
