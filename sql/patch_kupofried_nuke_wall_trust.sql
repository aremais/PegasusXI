-- Align live DB with repo fixes for Kupofried trust + status effect IDs 806/807.
-- Safe to run multiple times (idempotent for typical states).
--
-- 1) Kupofried has no TP weapon skills; skill_list_id 1093 had no mob_skill_lists rows.
-- 2) kupofried_aura must be id 807; id 806 is nuke_wall (matches src/map/status_effect.h + scripts/enum/effect.lua).

UPDATE `mob_pools`
SET `skill_list_id` = 0
WHERE `poolid` = 5978 AND `name` = 'kupofried';

-- Old mistake: kupofried_aura lived on 806 (NUKE_WALL slot). Rename + reset columns.
UPDATE `status_effects`
SET
    `name`                = 'nuke_wall',
    `flags`               = 288,
    `type`                = 0,
    `negative_id`         = 0,
    `overwrite`           = 0,
    `block_id`            = 0,
    `remove_id`           = 0,
    `element`             = 0,
    `min_duration`        = 0,
    `sort_key`            = 0,
    `wear_off_message_id` = NULL
WHERE `id` = 806 AND `name` = 'kupofried_aura';

-- If id 806 is missing entirely, add nuke_wall.
INSERT INTO `status_effects` (`id`, `name`, `flags`, `type`, `negative_id`, `overwrite`, `block_id`, `remove_id`, `element`, `min_duration`, `sort_key`, `wear_off_message_id`)
SELECT 806, 'nuke_wall', 288, 0, 0, 0, 0, 0, 0, 0, 0, NULL
WHERE NOT EXISTS (SELECT 1 FROM `status_effects` WHERE `id` = 806);

-- Ensure kupofried_aura exists at 807 (server MAX_EFFECTID / Lua xi.effect.KUPOFRIED_AURA).
INSERT INTO `status_effects` (`id`, `name`, `flags`, `type`, `negative_id`, `overwrite`, `block_id`, `remove_id`, `element`, `min_duration`, `sort_key`, `wear_off_message_id`)
VALUES (807, 'kupofried_aura', 288, 247, 0, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE
    `name`                = 'kupofried_aura',
    `flags`               = 288,
    `type`                = 247,
    `negative_id`         = 0,
    `overwrite`           = 0,
    `block_id`            = 0,
    `remove_id`           = 0,
    `element`             = 0,
    `min_duration`        = 0,
    `sort_key`            = 0,
    `wear_off_message_id` = NULL;

-- 288 = @FLAG_DEATH (32) | @FLAG_ON_ZONE (256)
