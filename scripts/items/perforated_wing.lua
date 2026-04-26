-----------------------------------
-- ID: 5904
-- Item: Perforated Wing
-- Dynamis - Qufim: Removes Antaeus's damage boost (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_qufim_antaeus')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.qufimAntaeusItemCheck(target, 'DynamisAntaeusWing')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.qufimAntaeusItemUse(target, user, 'DynamisAntaeusWing', function(mob)
        mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 100)
    end)
end

return itemObject
