-- Map server (spell.cpp) expects blue_spell_list.knockback; older DB dumps lack this column.
-- Matches sql/blue_spell_list.sql. Run once against your xi database; safe to skip if column exists.

ALTER TABLE `blue_spell_list`
  ADD COLUMN `knockback` smallint(2) unsigned NULL DEFAULT NULL AFTER `tertiary_sc`;

-- Values from sql/blue_spell_list.sql (non-NULL knockback only; rest stay NULL)
UPDATE `blue_spell_list` SET `knockback` = 1 WHERE `spellid` = 567 AND `mob_skill_id` = 622;
UPDATE `blue_spell_list` SET `knockback` = 2 WHERE `spellid` = 585 AND `mob_skill_id` = 266;
UPDATE `blue_spell_list` SET `knockback` = 2 WHERE `spellid` = 594 AND `mob_skill_id` = 584;
UPDATE `blue_spell_list` SET `knockback` = 1 WHERE `spellid` = 623 AND `mob_skill_id` = 612;
UPDATE `blue_spell_list` SET `knockback` = 3 WHERE `spellid` = 648 AND `mob_skill_id` = 2153;
UPDATE `blue_spell_list` SET `knockback` = 4 WHERE `spellid` = 688 AND `mob_skill_id` = 675;
