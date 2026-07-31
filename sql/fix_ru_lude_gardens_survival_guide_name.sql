-- Fix Ru'Lude Gardens Survival Guide (npcid 17772854, map I-10 area).
--
-- Both columns matter:
--   polutils_name -> label when targeting (client packet name)
--   name            -> script file (npcs/<name>.lua); must be Survival_Guide for the default script
--
-- If only polutils_name is wrong, targeting shows the wrong label.
-- If `name` is Syndella, the server loads Syndella.lua (repo provides a fallback) but you should still fix the row.
--
-- Fresh imports from npc_list.sql already have the correct values.
-- Run once against MariaDB/MySQL, then restart the map server.
--
-- Verify before/after:
--   SELECT npcid, name, polutils_name, content_tag FROM npc_list WHERE npcid = 17772854;

UPDATE `npc_list`
SET
    `name` = 'Survival_Guide',
    `polutils_name` = 'Survival Guide'
WHERE
    `npcid` = 17772854;
