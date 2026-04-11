-- Heavens Tower (242): spawn missing npcid 17768518 (targid 70)
--
-- That slot was left as NOT_CAPTURED in npc_list; the retail client still expects the entity
-- and repeatedly sends 0x016 (GP_CLI_COMMAND_CHARREQ), producing:
--   Could not look up entity <70, 17768518> in zone <Heavens_Tower (242)>
--
-- Run once against your database, then restart the map server (or reload the zone).

INSERT INTO `npc_list` VALUES (17768518,'blank','',0,0.000,0.000,0.000,0,40,40,0,0,0,2,3,0x0000320000000000000000000000000000000000,0,NULL,1);
