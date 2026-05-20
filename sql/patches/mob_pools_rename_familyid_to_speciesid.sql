-- Align mob_pools with server SQL (joins mob_species_system.speciesID).
-- Renames legacy `familyid` to `speciesid`. Safe to re-run if already migrated.
-- Data semantics are unchanged (values are species IDs, not taxonomy family IDs).

SET @db := DATABASE();
SET @has_familyid := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'mob_pools'
    AND COLUMN_NAME = 'familyid'
);
SET @sql := IF(
  @has_familyid > 0,
  'ALTER TABLE `mob_pools` CHANGE COLUMN `familyid` `speciesid` smallint(4) unsigned NOT NULL DEFAULT 0',
  'SELECT ''mob_pools.speciesid already present; skipping rename'' AS `patch_mob_pools_rename_familyid_to_speciesid`'
);
PREPARE `stmt_patch_mob_pools_speciesid` FROM @sql;
EXECUTE `stmt_patch_mob_pools_speciesid`;
DEALLOCATE PREPARE `stmt_patch_mob_pools_speciesid`;
