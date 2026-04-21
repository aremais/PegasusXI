-- =============================================================================
-- LOCAL / SERVER-OWNED — not dependent on upstream repo dumps being applied.
-- Fixes AAGK trust (pool 5996) combat skill / weapon type to Great Katana.
-- Safe to re-run: UPDATE on a single pool row.
-- =============================================================================

UPDATE `mob_pools`
SET `cmbSkill` = 10
WHERE `poolid` = 5996;