-----------------------------------
-- Area: Dynamis - Valkurm
--  Mob: Lost Fairy Ring
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.valkurmMarkChristelleWeakTier('miasmic')
end

return entity
