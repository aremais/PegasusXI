-- Rename Sprout Beret (15198) to Pegasus Beret.
-- Server-side name/script reference only; stats, mods, latents, and flags are unchanged.
--
-- Apply on live databases after deploying the matching server code changes:
--   scripts/items/pegasus_beret.lua
--   scripts/enum/item.lua (PEGASUS_BERET)
--
-- Client DAT edits are still required for in-game inventory/help text display.
-- See client_mods/Pegasus_Beret_Item_Name/README.md

SET @itemid := 15198;

UPDATE item_basic
SET
    name = 'pegasus_beret',
    sortname = 'pegasus_beret',
    name_jp = 'ペガサスベレー'
WHERE itemid = @itemid;

UPDATE item_equipment
SET name = 'pegasus_beret'
WHERE itemId = @itemid;

UPDATE item_usable
SET name = 'pegasus_beret'
WHERE itemId = @itemid;
