-- Heavens Tower (242): spawn missing npcid 17768518 (targid 70)
--
-- That slot was left as NOT_CAPTURED in npc_list; the retail client still expects the entity
-- and repeatedly sends 0x016 (GP_CLI_COMMAND_CHARREQ), producing:
--   Could not look up entity <70, 17768518> in zone <Heavens_Tower (242)>
--
-- Run against your database, then restart the map server (or reload the zone).
-- Idempotent: if npcid 17768518 already exists (duplicate PRIMARY), this refreshes the placeholder row.

INSERT INTO `npc_list` VALUES (17768518,'blank','',0,0.000,0.000,0.000,0,40,40,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,1)
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
    `look` = VALUES(`look`),
    `content_tag` = VALUES(`content_tag`),
    `widescan` = VALUES(`widescan`);
