-- San d'Oria: hide nameplates on CHARREQ-gap placeholder NPCs (namevis = VIS_HIDE_NAME / 0x08).
-- Without this, equipped-model placeholders show the literal DB name "blank" during the new-character opening.
--
-- Safe to re-run. Apply once, then restart map or reload zones 230–231.
UPDATE `npc_list` SET `namevis` = 8 WHERE `npcid` BETWEEN 17719973 AND 17719998;
UPDATE `npc_list` SET `namevis` = 8 WHERE `npcid` = 17719972;
UPDATE `npc_list` SET `namevis` = 8 WHERE `npcid` = 17723822;
