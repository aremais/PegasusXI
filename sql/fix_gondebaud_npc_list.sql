-- Southern San d'Oria (230) Gondebaud visual/nameplate sync.
UPDATE `npc_list`
SET
    `animationsub` = 0,
    `widescan` = 1,
    `name_prefix` = 0,
    `entityFlags` = 1
WHERE `npcid` = 17720000;
