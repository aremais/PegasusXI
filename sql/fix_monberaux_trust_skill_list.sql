-- Trust Monberaux (pool 5999): skill_list_id 1114 + mob_skill_lists so LoadTrustStatsAndSkills
-- does not warn (tp_skills empty). Run once, then restart the map server.
--
-- If you see ERROR 2006 "Server has gone away" on SOURCE, the server or client dropped the
-- connection (wait_timeout, max_allowed_packet, restart). Re-run SOURCE; INSERT IGNORE is idempotent.
-- Second run: UPDATE may show Changed: 0; INSERTs may show 0 rows + warnings (duplicate key) — expected.

UPDATE `mob_pools` SET `skill_list_id` = 1114 WHERE `poolid` = 5999;

INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
('TRUST_Monberaux',1114,4231),('TRUST_Monberaux',1114,4232),('TRUST_Monberaux',1114,4233),('TRUST_Monberaux',1114,4234),
('TRUST_Monberaux',1114,4235),('TRUST_Monberaux',1114,4236),('TRUST_Monberaux',1114,4237),('TRUST_Monberaux',1114,4238),
('TRUST_Monberaux',1114,4239),('TRUST_Monberaux',1114,4240),('TRUST_Monberaux',1114,4241),('TRUST_Monberaux',1114,4242),
('TRUST_Monberaux',1114,4243),('TRUST_Monberaux',1114,4244),('TRUST_Monberaux',1114,4245),('TRUST_Monberaux',1114,4246),
('TRUST_Monberaux',1114,4247),('TRUST_Monberaux',1114,4248),('TRUST_Monberaux',1114,4249),('TRUST_Monberaux',1114,4250),
('TRUST_Monberaux',1114,4251),('TRUST_Monberaux',1114,4252),('TRUST_Monberaux',1114,4253),('TRUST_Monberaux',1114,4254),
('TRUST_Monberaux',1114,4255),('TRUST_Monberaux',1114,4256),('TRUST_Monberaux',1114,4257),('TRUST_Monberaux',1114,4258),
('TRUST_Monberaux',1114,4259),('TRUST_Monberaux',1114,4260),('TRUST_Monberaux',1114,4261);
