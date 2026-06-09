-- Restore Judge's Rod as fishing/non-combat gear.
-- 17012 judges_rod is a fishing rod, not a caster weapon.
-- Remove custom GM combat/caster mods and restore original weapon damage/delay.

UPDATE item_weapon
SET
    dmg = 0,
    delay = 240
WHERE itemId = 17012;

DELETE FROM item_mods
WHERE itemId = 17012;

DELETE FROM item_latents
WHERE itemId = 17012;
