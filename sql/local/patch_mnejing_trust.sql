-- Enable Mnejing trust skill list

UPDATE mob_pools
SET skill_list_id = 1041
WHERE poolid = 5926;

INSERT INTO mob_skill_lists
VALUES ('TRUST_Mnejing', 1041, 0);