-- Zone 82 campaign spawn references group 148; mob_groups only had Eurytos_campaign (348).
INSERT INTO `mob_groups` VALUES (148, 1262, 82, 'Eurytos', 0, 128, 0, 0, 0, 75, 75, 0, NULL)
ON DUPLICATE KEY UPDATE `poolid`=VALUES(`poolid`), `name`=VALUES(`name`);
