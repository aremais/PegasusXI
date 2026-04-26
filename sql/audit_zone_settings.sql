-- Run against xidb after updates / FFXI-3001. Replace nothing; read-only checks.
-- Internet players need a routable IPv4 in zoneip for every zoneport you actually use.

SELECT 'distinct map endpoints (what login can send to clients)' AS check_name;
SELECT zoneip, zoneport, COUNT(*) AS zone_rows
FROM zone_settings
GROUP BY zoneip, zoneport
ORDER BY zoneport, zoneip;

SELECT 'rows still on localhost with a non-zero map port (usually breaks remote clients)' AS check_name;
SELECT COUNT(*) AS cnt FROM zone_settings WHERE zoneip = '127.0.0.1' AND zoneport > 0;

SELECT 'rows with empty zoneip but non-zero port (invalid)' AS check_name;
SELECT COUNT(*) AS cnt FROM zone_settings WHERE (zoneip IS NULL OR zoneip = '') AND zoneport > 0;
