-- Raise display-name column limits (polutils_name / packet_name).
-- Client 0x00E long-name layout supports up to 19 visible characters; DB may store longer for tooling.
ALTER TABLE `mob_pools` MODIFY `packet_name` varchar(32) DEFAULT NULL;
