-- Talacca Cove (57): spawn missing npcid 17010904 (targid 216)
--
-- Required for the Luck of the Draw final cutscene at the Rock Slab (_1l0).
-- Without this row the client polls targid 216 with 0x016 CHARREQ and the map logs:
--   Could not look up entity <216, 17010904> in zone <Talacca_Cove (57)>
-- The player soft-locks when checking the Rock Slab at quest progress 4.
--
-- Also updates 17010903 if it still has the old csnpc placeholder at the wrong slot.
--
-- Run once against your database, then restart the map server (or reload zone 57).
-- Safe to re-run: INSERT IGNORE skips duplicates; UPDATE is idempotent.

INSERT IGNORE INTO `npc_list` VALUES (17010904,'Qultada','Qultada',219,18.846,-0.449,176.990,0,50,50,0,0,0,6,27,0x01000003A710A720A730A740A750AF6000700000,32,'TOAU',1);

UPDATE `npc_list` SET
    `name` = 'Qultada',
    `polutils_name` = 'Qultada',
    `pos_rot` = 215,
    `pos_x` = 8.148,
    `pos_y` = -0.441,
    `pos_z` = 171.151,
    `flag` = 32
WHERE `npcid` = 17010903;
