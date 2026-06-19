-- Add minLevel/maxLevel to mob_groups for upstream mob group level data.
-- Safe to re-run if the columns already exist.

SET @db := DATABASE();
SET @has_min_level := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'mob_groups'
    AND COLUMN_NAME = 'minLevel'
);
SET @sql := IF(
  @has_min_level = 0,
  'ALTER TABLE `mob_groups` ADD COLUMN `minLevel` tinyint(2) unsigned NOT NULL DEFAULT 0 AFTER `MP`, ADD COLUMN `maxLevel` tinyint(2) unsigned NOT NULL DEFAULT 0 AFTER `minLevel`',
  'SELECT ''mob_groups.minLevel/maxLevel already present; skipping add'' AS `patch_mob_groups_add_min_max_level`'
);
PREPARE `stmt_patch_mob_groups_min_max_level` FROM @sql;
EXECUTE `stmt_patch_mob_groups_min_max_level`;
DEALLOCATE PREPARE `stmt_patch_mob_groups_min_max_level`;
