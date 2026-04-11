-- Point all zones at the public map/listener address so clients outside the server's LAN can zone in.
-- **Edit the IP** before running (example uses TEST-NET-2 documentation address only).
-- Safe to re-run: only updates rows still on 127.0.0.1.
--
-- After `dbtool update`, zone_settings is no longer overwritten from the repo (see tools/dbtool.py
-- protected `zone_settings.sql`). If you updated before that change, a DB import may have reset
-- zoneip to 127.0.0.1 and caused FFXI-3001 for remote players.

UPDATE `zone_settings` SET `zoneip` = '198.51.100.1' WHERE `zoneip` = '127.0.0.1';
