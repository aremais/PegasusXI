-----------------------------------
-- ID: 5900
-- Item: Shadescale Talon
-- Dynamis - Buburimu: locks Chaos Blade and Petro Eyes (bg-wiki)
-----------------------------------
require('scripts/globals/dynamis_buburimu_apocalyptic')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.buburimuApocalypticItemCheck(target, 'DynamisApocalypticShadescaleTalon')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.buburimuApocalypticItemUse(target, user, 'DynamisApocalypticShadescaleTalon')
end

return itemObject
