-- Rename Chocobo Shirt (10293) to Pegasus Tunic.
-- Server-side name/script reference only; stats, mods, latents, and flags are unchanged.
--
-- Apply on live databases after deploying the matching server code changes:
--   scripts/items/pegasus_tunic.lua
--   scripts/enum/item.lua (PEGASUS_TUNIC)
--
-- Client DAT edits are still required for in-game inventory/help text display.
-- See client_mods/Pegasus_Tunic_Item_Name/README.md

SET @itemid := 10293;

UPDATE item_basic
SET
    name = 'pegasus_tunic',
    sortname = 'pegasus_tunic',
    name_jp = 'ペガサスタニック'
WHERE itemid = @itemid;

UPDATE item_equipment
SET name = 'pegasus_tunic'
WHERE itemId = @itemid;

UPDATE item_usable
SET name = 'pegasus_tunic'
WHERE itemId = @itemid;
