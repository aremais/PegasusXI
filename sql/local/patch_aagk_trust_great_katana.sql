-- =============================================================================
-- LOCAL / SERVER-OWNED - not dependent on upstream repo dumps being applied.
-- Fixes AAGK trust (pool 5996) combat skill / weapon type to Great Katana.
-- Safe to re-run: UPDATE on a single pool row.
--
-- Usage (example):
--   mysql -u USER -p DATABASE < sql/local/patch_aagk_trust_great_katana.sql
-- =============================================================================

UPDATE `mob_pools`
SET `cmbSkill` = 10
WHERE `poolid` = 5996;