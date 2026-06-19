-- Mammet mob pools used speciesid 503 (Mammet family) instead of 483 (Mammet species).
-- Zone load INNER JOIN mob_species_system then fails and BCNM mammets never spawn.

UPDATE `mob_pools`
SET `speciesid` = 483
WHERE `poolid` IN (2499, 2500, 2501, 2502)
  AND `speciesid` = 503;
