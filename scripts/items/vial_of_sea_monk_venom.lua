-----------------------------------
-- ID: 5903
-- Item: Vial of Sea Monk Venom
-- Dynamis - Qufim: Removes Antaeus's Regen (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_qufim_antaeus')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.qufimAntaeusItemCheck(target, 'DynamisAntaeusVenom')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.qufimAntaeusItemUse(target, user, 'DynamisAntaeusVenom', function(mob)
        local amt = mob:getLocalVar('DynamisAntaeusRegen')
        if amt > 0 then
            mob:addMod(xi.mod.REGEN, -amt)
            mob:setLocalVar('DynamisAntaeusRegen', 0)
        end
    end)
end

return itemObject
