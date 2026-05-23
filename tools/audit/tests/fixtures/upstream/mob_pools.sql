CREATE TABLE `mob_pools` (`poolid` int) ENGINE=Aria;
-- Goblin_Tinkerer: upstream has aggro=0, links=0 (local has aggro=1, links=1)
INSERT INTO `mob_pools` VALUES (100,'Goblin_Tinkerer','Goblin_Tinkerer',50,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,0,0,0,0,0,0,0,3,0,0,0,0,0,12,12,1,12);
-- River_Crab: same pool fields, but no MOBMOD_DETECTION override -> effective detects differ
INSERT INTO `mob_pools` VALUES (101,'River_Crab','River_Crab',60,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,12);
-- Upstream-only pool 103
INSERT INTO `mob_pools` VALUES (103,'Upstream_Only_Mob','Upstream_Only_Mob',80,0x010005019510A220A230A240A250BC60B7703A80,5,5,3,240,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,12);
