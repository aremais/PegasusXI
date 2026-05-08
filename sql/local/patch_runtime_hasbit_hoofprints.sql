-- =============================================================================
-- LOCAL / SERVER-OWNED - live DB repair for runtime log spam observed 2026-05-06.
--
-- Fixes:
--   * hasBit out-of-range errors from bad learned-ability rows using mob-skill IDs.
--   * Missing Warhorse Hoofprint NPC rows in TOAU zones.
--
-- Usage:
--   Apply with your MariaDB client, then restart xi_map so NPC and ability caches reload.
-- =============================================================================

SET NAMES utf8mb4;

-- Ability IDs are bit-indexed in CCharEntity::m_Abilities/m_LearnedAbilities.
-- These observed IDs are mob-skill IDs, not valid player ability IDs.
DELETE FROM `abilities`
WHERE `abilityId` IN (3415, 3416, 3417, 3418, 3421);

-- Source npc_list.sql already contains three dynamic hoofprints in each zone.
-- Reinsert them idempotently for live databases that are missing the rows.
INSERT INTO `npc_list` VALUES
(16986609,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(16986610,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(16986611,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(16990597,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(16990598,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(16990599,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17027511,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17027512,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17027513,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17101288,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17101289,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1),
(17101290,'Warhorse_Hoofprint','Warhorse Hoofprint',0,1.000,0.000,0.000,7,40,40,0,0,32,2,27,0x0000340000000000000000000000000000000000,32,'TOAU',1)
ON DUPLICATE KEY UPDATE
    `polutils_name` = VALUES(`polutils_name`),
    `name`          = VALUES(`name`),
    `status`        = VALUES(`status`),
    `content_tag`   = VALUES(`content_tag`);
