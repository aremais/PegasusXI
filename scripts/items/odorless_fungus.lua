-----------------------------------
-- ID: 5895
-- Item: Odorless Fungus
-- Dynamis - Valkurm: Locks Cirrate Christelle's Miasmic Breath; removes move-speed boost (bg-wiki).
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.dynamis.valkurmChristelleItemCheck(target, 'DynamisChristelleFungus')
end

itemObject.onItemUse = function(target, user, item, action)
    xi.dynamis.valkurmChristelleItemUse(target, user, 'DynamisChristelleFungus', function(mob)
        local mult = mob:getMobMod(xi.mobMod.RUN_SPEED_MULT)
        if mult > 100 then
            mob:setMobMod(xi.mobMod.RUN_SPEED_MULT, 100)
        end
    end)
end

return itemObject
