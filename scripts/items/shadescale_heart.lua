-----------------------------------
-- ID: 5901
-- Item: Shadescale Heart
-- Dynamis - Buburimu: locks Nullsong, Thornsong, and Lodesong (bg-wiki)
-----------------------------------
require('scripts/globals/dynamis_buburimu_apocalyptic')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.buburimuApocalypticItemCheck(target, 'DynamisApocalypticShadescaleHeart')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.buburimuApocalypticItemUse(target, user, 'DynamisApocalypticShadescaleHeart')
end

return itemObject
