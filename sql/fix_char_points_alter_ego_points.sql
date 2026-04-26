-- One-time schema fix for newer map binaries.
-- Resolves:
--   Fatal Exception: No such column: alter_ego_points

ALTER TABLE `char_points`
ADD COLUMN IF NOT EXISTS `alter_ego_points` smallint(5) unsigned NOT NULL DEFAULT 0;

