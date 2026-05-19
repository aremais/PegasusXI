-- Align mob_pools with server SQL (joins mob_species_system.speciesID).
-- Run on existing DBs that still use the legacy column name `familyid`.
-- Data semantics are unchanged (values are species IDs, not taxonomy family IDs).

ALTER TABLE `mob_pools`
  CHANGE COLUMN `familyid` `speciesid` smallint(4) unsigned NOT NULL DEFAULT 0;
