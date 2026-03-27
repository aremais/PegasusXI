-- Fix Ru'Lude Gardens Survival Guide display name
--
-- Some environments have the Ru'Lude Gardens survival guide NPC showing as "Syndella"
-- instead of "Survival Guide" (client UI uses npc_list.polutils_name / name fields).
--
-- This updates the NPC(s) in zone 243 to the expected names.
-- Some setups have the display name saved as "Syndella" even though the content_tag/script are correct.
-- Run once against your MariaDB, then restart the map server.

UPDATE `npc_list`
SET
    `name` = 'Survival_Guide',
    `polutils_name` = 'Survival Guide'
WHERE
    ((`npcid` >> 12) & 0xFFF) = 243
    AND (
        `content_tag` = 'SURVIVAL_GUIDE'
        OR `polutils_name` = 'Syndella'
        OR `name` = 'Syndella'
    );

