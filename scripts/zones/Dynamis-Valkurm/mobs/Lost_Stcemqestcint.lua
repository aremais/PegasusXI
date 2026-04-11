-----------------------------------
-- Area: Dynamis - Valkurm
--  Mob: Lost Stcemqestcint
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.valkurmMarkChristelleWeakTier('putrid')
end

return entity
