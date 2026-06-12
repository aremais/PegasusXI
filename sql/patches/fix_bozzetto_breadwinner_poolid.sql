-- mob_pools defines Bozzetto_Breadwinner at poolid 30001, not 30000.
UPDATE `mob_groups` SET `poolid` = 30001 WHERE `zoneid` = 287 AND `groupid` = 38 AND `name` = 'Bozzetto_Breadwinner' AND `poolid` = 30000;
