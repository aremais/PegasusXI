-- GM Judge Weapon Delay Patch
-- Damage is handled by gm_judge_weapon_tiered_damage.sql using base dmg + DMG_RATING latents.
-- This file only keeps intended weapon delays.

UPDATE item_weapon
SET delay = 240
WHERE itemId = 16622; -- Judge's Sword, physical melee

UPDATE item_weapon
SET delay = 224
WHERE itemId = 17644; -- Judge's Sword, magic/utility

UPDATE item_weapon
SET delay = 540
WHERE itemId = 17174; -- Judge's Bow, ranged

UPDATE item_weapon
SET delay = 120
WHERE itemId = 17326; -- Judge's Arrow, ammo
