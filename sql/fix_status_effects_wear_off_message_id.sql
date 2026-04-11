-- One-time schema fix for newer server binaries.
-- Adds the missing column expected by map server:
--   Unknown column 'wear_off_message_id' in 'field list'

ALTER TABLE `status_effects`
ADD COLUMN IF NOT EXISTS `wear_off_message_id` smallint(5) unsigned DEFAULT NULL
AFTER `sort_key`;

