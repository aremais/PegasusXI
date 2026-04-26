-- Repair: remove rows in char_* tables that have no matching `chars` row.
-- These orphans make BEFORE INSERT `char_insert` fail with Duplicate entry 'N-0' on char_inventory
-- when creating a new character (MAX(charid)+1 collides with leftover child rows).
--
-- Safe to run anytime; only deletes dangling rows.

DELETE ci FROM `char_inventory` ci
LEFT JOIN `chars` c ON c.`charid` = ci.`charid`
WHERE c.`charid` IS NULL;

DELETE ce FROM `char_equip` ce
LEFT JOIN `chars` c ON c.`charid` = ce.`charid`
WHERE c.`charid` IS NULL;

DELETE cx FROM `char_exp` cx
LEFT JOIN `chars` c ON c.`charid` = cx.`charid`
WHERE c.`charid` IS NULL;

DELETE ch FROM `char_history` ch
LEFT JOIN `chars` c ON c.`charid` = ch.`charid`
WHERE c.`charid` IS NULL;

DELETE cj FROM `char_jobs` cj
LEFT JOIN `chars` c ON c.`charid` = cj.`charid`
WHERE c.`charid` IS NULL;

DELETE cp FROM `char_pet` cp
LEFT JOIN `chars` c ON c.`charid` = cp.`charid`
WHERE c.`charid` IS NULL;

DELETE cpp FROM `char_points` cpp
LEFT JOIN `chars` c ON c.`charid` = cpp.`charid`
WHERE c.`charid` IS NULL;

DELETE cpr FROM `char_profile` cpr
LEFT JOIN `chars` c ON c.`charid` = cpr.`charid`
WHERE c.`charid` IS NULL;

DELETE cs FROM `char_storage` cs
LEFT JOIN `chars` c ON c.`charid` = cs.`charid`
WHERE c.`charid` IS NULL;

DELETE cu FROM `char_unlocks` cu
LEFT JOIN `chars` c ON c.`charid` = cu.`charid`
WHERE c.`charid` IS NULL;

DELETE t FROM `char_effects` t
LEFT JOIN `chars` c ON c.`charid` = t.`charid`
WHERE c.`charid` IS NULL;

DELETE t FROM `char_style` t
LEFT JOIN `chars` c ON c.`charid` = t.`charid`
WHERE c.`charid` IS NULL;
