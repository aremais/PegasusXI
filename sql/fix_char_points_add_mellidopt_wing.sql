-- Adds support for Mellidopt Wings Stored currency display.
ALTER TABLE `char_points`
    ADD COLUMN IF NOT EXISTS `mellidopt_wing` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0' AFTER `pulchridopt_wing`;
