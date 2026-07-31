-----------------------------------
-- ID: 5905
-- Item: Undying Moiety
-- Dynamis - Qufim: Removes Antaeus's per-hit damage soft cap (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_qufim_antaeus')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.qufimAntaeusItemCheck(target, 'DynamisAntaeusMoiety')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.qufimAntaeusItemUse(target, user, 'DynamisAntaeusMoiety', function(mob)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_CAP, 0)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_VARIANT, 0)
    end)
end

return itemObject
