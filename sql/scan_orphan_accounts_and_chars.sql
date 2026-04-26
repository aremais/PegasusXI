-- Read-only report: rows not hooked to a valid account and/or character.
-- Run against `xidb`: mysql ... xidb < sql/scan_orphan_accounts_and_chars.sql
--
-- Sections:
--   A) Counts per table (0 = OK)
--   B) chars.accid that does not exist in accounts (active characters only; accid <> 0)
--   C) Optional: list "deleted" chars (accid = 0) — expected for recovered/deleted chars

SET NAMES utf8;

-- ---------------------------------------------------------------------------
-- A) Orphan row counts (child rows with no matching `chars` row)
-- ---------------------------------------------------------------------------
SELECT '--- A) orphan charid (no row in chars) ---' AS section;

SELECT 'char_blacklist (owner)' AS tbl, COUNT(*) AS orphan_rows
FROM char_blacklist b LEFT JOIN chars c ON c.charid = b.charid_owner WHERE c.charid IS NULL
UNION ALL SELECT 'char_blacklist (target)', COUNT(*)
FROM char_blacklist b LEFT JOIN chars c ON c.charid = b.charid_target WHERE c.charid IS NULL
UNION ALL SELECT 'char_chocobos', COUNT(*) FROM char_chocobos t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_effects', COUNT(*) FROM char_effects t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_equip', COUNT(*) FROM char_equip t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_equip_saved', COUNT(*) FROM char_equip_saved t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_exp', COUNT(*) FROM char_exp t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_fishing_contest_history', COUNT(*) FROM char_fishing_contest_history t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_flags', COUNT(*) FROM char_flags t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_history', COUNT(*) FROM char_history t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_inventory', COUNT(*) FROM char_inventory t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_jobs', COUNT(*) FROM char_jobs t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_job_points', COUNT(*) FROM char_job_points t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_look', COUNT(*) FROM char_look t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_merit', COUNT(*) FROM char_merit t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_monstrosity', COUNT(*) FROM char_monstrosity t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_pet', COUNT(*) FROM char_pet t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_points', COUNT(*) FROM char_points t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_profile', COUNT(*) FROM char_profile t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_recast', COUNT(*) FROM char_recast t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_skills', COUNT(*) FROM char_skills t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_spells', COUNT(*) FROM char_spells t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_stats', COUNT(*) FROM char_stats t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_storage', COUNT(*) FROM char_storage t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_style', COUNT(*) FROM char_style t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_unlocks', COUNT(*) FROM char_unlocks t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'char_vars', COUNT(*) FROM char_vars t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'delivery_box (charid)', COUNT(*) FROM delivery_box t LEFT JOIN chars c ON c.charid = t.charid WHERE c.charid IS NULL
UNION ALL SELECT 'audit_bazaar (seller)', COUNT(*) FROM audit_bazaar t LEFT JOIN chars c ON c.charid = t.seller WHERE c.charid IS NULL AND t.seller != 0
UNION ALL SELECT 'audit_dbox (sender)', COUNT(*) FROM audit_dbox t LEFT JOIN chars c ON c.charid = t.sender WHERE c.charid IS NULL AND t.sender != 0
UNION ALL SELECT 'audit_dbox (receiver)', COUNT(*) FROM audit_dbox t LEFT JOIN chars c ON c.charid = t.receiver WHERE c.charid IS NULL AND t.receiver != 0
;

-- Tables that reference char by another column name
SELECT 'auction_house (seller)', COUNT(*) AS orphan_rows
FROM auction_house t LEFT JOIN chars c ON c.charid = t.seller WHERE c.charid IS NULL AND t.seller != 0
UNION ALL
SELECT 'account_ip_record (charid>0)', COUNT(*)
FROM account_ip_record t LEFT JOIN chars c ON c.charid = t.charid WHERE t.charid != 0 AND c.charid IS NULL
;

-- ---------------------------------------------------------------------------
-- B) chars.accid not present in accounts (broken link; excludes accid = 0)
-- ---------------------------------------------------------------------------
SELECT '--- B) chars with invalid accid (not in accounts, accid <> 0) ---' AS section;

SELECT ch.charid, ch.charname, ch.accid
FROM chars ch
LEFT JOIN accounts a ON a.id = ch.accid
WHERE ch.accid != 0 AND a.id IS NULL;

-- ---------------------------------------------------------------------------
-- C) Sessions: accid or charid not matching reality
-- ---------------------------------------------------------------------------
SELECT '--- C) accounts_sessions ---' AS section;

SELECT 'session: charid not in chars' AS issue, COUNT(*) AS cnt
FROM accounts_sessions s LEFT JOIN chars c ON c.charid = s.charid WHERE c.charid IS NULL
UNION ALL
SELECT 'session: accid not in accounts', COUNT(*)
FROM accounts_sessions s LEFT JOIN accounts a ON a.id = s.accid WHERE s.accid != 0 AND a.id IS NULL
;

-- ---------------------------------------------------------------------------
-- D) Rows keyed by accid with no matching account
-- ---------------------------------------------------------------------------
SELECT '--- D) accid orphans (not in accounts) ---' AS section;

SELECT 'accounts_banned' AS tbl, COUNT(*) AS orphan_rows
FROM accounts_banned t LEFT JOIN accounts a ON a.id = t.accid WHERE a.id IS NULL
UNION ALL SELECT 'ip_exceptions', COUNT(*) FROM ip_exceptions t LEFT JOIN accounts a ON a.id = t.accid WHERE a.id IS NULL
UNION ALL SELECT 'account_ip_record (accid)', COUNT(*) FROM account_ip_record t LEFT JOIN accounts a ON a.id = t.accid WHERE a.id IS NULL
;

-- ---------------------------------------------------------------------------
-- E) Informational: deleted-character rows (accid = 0), not an error by itself
-- ---------------------------------------------------------------------------
SELECT '--- E) chars with accid=0 (deleted / recovery pool) count ---' AS section;

SELECT COUNT(*) AS deleted_chars_accid_zero FROM chars WHERE accid = 0;
