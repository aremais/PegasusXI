-- BUG-0055 / Zeruhn Lasthenes gate -> Korroloka
-- Run this after: merging upstream, re-importing sql/zonelines.sql, or restoring DB from an LSB dump.
-- Upstream MAPRECT check uses from_pos within 40y of the player; LSB still uses (-273,12,-20) instead of the
-- real gate at npc _4s0 (-80,-2.725,20), so zoning fails after the cutscene until these rows are corrected.
-- After applying: restart map-server (zonelines load at zone init).

UPDATE `zonelines`
SET `from_pos_x` = -80.000, `from_pos_y` = -2.725, `from_pos_z` = 20.000
WHERE `zonelineid` = 846410874 AND `from_zone` = 172 AND `to_zone` = 173;

UPDATE `zonelines`
SET `to_pos_x` = -79.500, `to_pos_y` = -2.725, `to_pos_z` = 20.000
WHERE `zonelineid` = 812921978 AND `from_zone` = 173 AND `to_zone` = 172;
