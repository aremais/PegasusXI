-- BUG-0055: Lasthenes / Korroloka gate — MAPRECT distance check uses zoneline from_pos.
-- Old anchors (-273, 12.8, -20) were ~200y from the real gate (-80, -2.725, 20), so zoning
-- always failed with "You could not enter the next area" after the cutscene.
UPDATE `zonelines`
SET `from_pos_x` = -80.000, `from_pos_y` = -2.725, `from_pos_z` = 20.000
WHERE `zonelineid` = 846410874 AND `from_zone` = 172 AND `to_zone` = 173;

UPDATE `zonelines`
SET `to_pos_x` = -79.500, `to_pos_y` = -2.725, `to_pos_z` = 20.000
WHERE `zonelineid` = 812921978 AND `from_zone` = 173 AND `to_zone` = 172;
