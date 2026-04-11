-- Point all zones at the public map/listener address so clients outside the server's LAN can zone in.
-- Edit the IP below if your host changes. Safe to re-run: only updates rows still on 127.0.0.1.
-- Matches settings/network.lua LOGIN_* / MAP use of the same host when all map traffic uses one IP.

UPDATE `zone_settings` SET `zoneip` = '74.208.165.117' WHERE `zoneip` = '127.0.0.1';
