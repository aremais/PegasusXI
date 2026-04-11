-----------------------------------
-- ID: 5896
-- Item: Clump of Absorbent Moss
-- Dynamis - Valkurm: Locks Cirrate Christelle's Fragrant Breath (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.valkurmChristelleItemCheck(target, 'DynamisChristelleMoss')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.valkurmChristelleItemUse(target, user, 'DynamisChristelleMoss')
end

return itemObject
