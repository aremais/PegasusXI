-----------------------------------
-- Area: Dynamis - Valkurm
--  Mob: Lost Nant'ina
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.valkurmMarkChristelleWeakTier('fragrant')
end

return entity
