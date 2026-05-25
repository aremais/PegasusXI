-- Map server (itemutils.cpp) expects item_equipment.rslot, rslotlook, and su_level.
-- Older DB dumps may lack these columns. Safe to re-run.

SET @db := DATABASE();

SET @has_rslot := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'item_equipment'
    AND COLUMN_NAME = 'rslot'
);
SET @sql := IF(
  @has_rslot = 0,
  'ALTER TABLE `item_equipment` ADD COLUMN `rslot` smallint(5) unsigned NOT NULL DEFAULT 0 AFTER `slot`',
  'SELECT ''item_equipment.rslot already present; skipping ADD'' AS `patch_item_equipment_rslot`'
);
PREPARE `stmt_patch_rslot` FROM @sql;
EXECUTE `stmt_patch_rslot`;
DEALLOCATE PREPARE `stmt_patch_rslot`;

SET @has_rslotlook := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'item_equipment'
    AND COLUMN_NAME = 'rslotlook'
);
SET @sql := IF(
  @has_rslotlook = 0,
  'ALTER TABLE `item_equipment` ADD COLUMN `rslotlook` smallint(5) unsigned NOT NULL DEFAULT 0 AFTER `rslot`',
  'SELECT ''item_equipment.rslotlook already present; skipping ADD'' AS `patch_item_equipment_rslotlook`'
);
PREPARE `stmt_patch_rslotlook` FROM @sql;
EXECUTE `stmt_patch_rslotlook`;
DEALLOCATE PREPARE `stmt_patch_rslotlook`;

SET @has_su_level := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'item_equipment'
    AND COLUMN_NAME = 'su_level'
);
SET @sql := IF(
  @has_su_level = 0,
  'ALTER TABLE `item_equipment` ADD COLUMN `su_level` tinyint(3) unsigned NOT NULL DEFAULT 0 AFTER `rslotlook`',
  'SELECT ''item_equipment.su_level already present; skipping ADD'' AS `patch_item_equipment_su_level`'
);
PREPARE `stmt_patch_su_level` FROM @sql;
EXECUTE `stmt_patch_su_level`;
DEALLOCATE PREPARE `stmt_patch_su_level`;

UPDATE `item_equipment` SET `rslot` = 0 WHERE `rslot` IS NULL;
UPDATE `item_equipment` SET `rslotlook` = 0 WHERE `rslotlook` IS NULL;
UPDATE `item_equipment` SET `su_level` = 0 WHERE `su_level` IS NULL;
