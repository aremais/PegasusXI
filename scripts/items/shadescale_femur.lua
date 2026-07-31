-----------------------------------
-- ID: 5899
-- Item: Shadescale Femur
-- Dynamis - Buburimu: locks Heavy Stomp and Body Slam (bg-wiki)
-----------------------------------
require('scripts/globals/dynamis_buburimu_apocalyptic')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.buburimuApocalypticItemCheck(target, 'DynamisApocalypticShadescaleFemur')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.buburimuApocalypticItemUse(target, user, 'DynamisApocalypticShadescaleFemur')
end

return itemObject
