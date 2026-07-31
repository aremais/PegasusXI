-----------------------------------
-- ID: 5898
-- Item: Shadescale Skull
-- Dynamis - Buburimu: locks flame / poison / wind breath (bg-wiki)
-----------------------------------
require('scripts/globals/dynamis_buburimu_apocalyptic')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.buburimuApocalypticItemCheck(target, 'DynamisApocalypticShadescaleSkull')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.buburimuApocalypticItemUse(target, user, 'DynamisApocalypticShadescaleSkull')
end

return itemObject
