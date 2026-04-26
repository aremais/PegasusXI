-----------------------------------
-- ID: 5897
-- Item: Redolent Root
-- Dynamis - Valkurm: Locks Vampiric Lash and Putrid Breath on Cirrate Christelle (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.valkurmChristelleItemCheck(target, 'DynamisChristelleRoot')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.valkurmChristelleItemUse(target, user, 'DynamisChristelleRoot')
end

return itemObject
