-- Talacca Cove (57): Corsair quest "Luck of the Draw" NPC fixes.
--
-- 1. qm1 look was corrupted by `UPDATE look = 57` (stores ASCII "57", not ??? model).
-- 2. npcid 17010904 (Qultada cutscene actor) was deleted; event 3 CHARREQ fails without it.
-- 3. npcid 17010922 (blank client poll stub) was deleted.
--
-- Run once, then restart the map server (or reload zone 57).

UPDATE `npc_list` SET
    `name` = 'qm1',
    `polutils_name` = '???',
    `pos_rot` = 117,
    `pos_x` = -61.516,
    `pos_y` = -9.905,
    `pos_z` = -138.676,
    `flag` = 1,
    `speed` = 50,
    `speedsub` = 50,
    `animation` = 0,
    `animationsub` = 0,
    `namevis` = 0,
    `status` = 0,
    `entityFlags` = 3,
    `look` = 0x0000340000000000000000000000000000000000,
    `name_prefix` = 0,
    `content_tag` = 'TOAU',
    `widescan` = 0
WHERE `npcid` = 17010918;

INSERT INTO `npc_list` VALUES (17010904,'Qultada','Qultada',219,18.846,-0.449,176.990,0,50,50,0,0,0,6,27,0x01000003A710A720A730A740A750AF6000700000,32,'TOAU',1)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `polutils_name` = VALUES(`polutils_name`),
    `pos_rot` = VALUES(`pos_rot`),
    `pos_x` = VALUES(`pos_x`),
    `pos_y` = VALUES(`pos_y`),
    `pos_z` = VALUES(`pos_z`),
    `flag` = VALUES(`flag`),
    `speed` = VALUES(`speed`),
    `speedsub` = VALUES(`speedsub`),
    `animation` = VALUES(`animation`),
    `animationsub` = VALUES(`animationsub`),
    `namevis` = VALUES(`namevis`),
    `status` = VALUES(`status`),
    `entityFlags` = VALUES(`entityFlags`),
    `look` = VALUES(`look`),
    `name_prefix` = VALUES(`name_prefix`),
    `content_tag` = VALUES(`content_tag`),
    `widescan` = VALUES(`widescan`);

INSERT INTO `npc_list` VALUES (17010922,'blank','',0,0.000,0.000,0.000,0,50,50,0,0,0,2,2051,0x0000340000000000000000000000000000000000,0,NULL,0)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `polutils_name` = VALUES(`polutils_name`),
    `pos_rot` = VALUES(`pos_rot`),
    `pos_x` = VALUES(`pos_x`),
    `pos_y` = VALUES(`pos_y`),
    `pos_z` = VALUES(`pos_z`),
    `flag` = VALUES(`flag`),
    `speed` = VALUES(`speed`),
    `speedsub` = VALUES(`speedsub`),
    `animation` = VALUES(`animation`),
    `animationsub` = VALUES(`animationsub`),
    `namevis` = VALUES(`namevis`),
    `status` = VALUES(`status`),
    `entityFlags` = VALUES(`entityFlags`),
    `look` = VALUES(`look`),
    `name_prefix` = VALUES(`name_prefix`),
    `content_tag` = VALUES(`content_tag`),
    `widescan` = VALUES(`widescan`);
