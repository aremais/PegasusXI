SELECT skill_list_id, mob_skill_id FROM mob_skill_lists
  WHERE skill_list_name IN ('Cirrate_Christelle','Arch_Christelle') AND skill_list_id IN (2010,2099)
  ORDER BY skill_list_id, mob_skill_id;
SELECT poolid, name, skill_list_id FROM mob_pools WHERE poolid = 354;
SELECT itemid, validTargets FROM item_usable WHERE itemid IN (5895,5896,5897);
