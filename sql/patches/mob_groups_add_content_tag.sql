-- Add content_tag to mob_groups for expansion-gated mob loading (zoneutils.cpp).
-- Safe to re-run if the column already exists.

SET @db := DATABASE();
SET @has_content_tag := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'mob_groups'
    AND COLUMN_NAME = 'content_tag'
);
SET @sql := IF(
  @has_content_tag = 0,
  'ALTER TABLE `mob_groups` ADD COLUMN `content_tag` varchar(14) DEFAULT NULL AFTER `allegiance`',
  'SELECT ''mob_groups.content_tag already present; skipping add'' AS `patch_mob_groups_add_content_tag`'
);
PREPARE `stmt_patch_mob_groups_content_tag` FROM @sql;
EXECUTE `stmt_patch_mob_groups_content_tag`;
DEALLOCATE PREPARE `stmt_patch_mob_groups_content_tag`;
