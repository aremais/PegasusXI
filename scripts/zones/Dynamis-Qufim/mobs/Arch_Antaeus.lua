-----------------------------------
-- Area: Dynamis - Qufim
--  Mob: Arch Antaeus
-- Note: Mega Boss
-----------------------------------
require('scripts/globals/dynamis_qufim_antaeus')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    xi.dynamis.qufimAntaeusOnSpawn(mob)
end

-- Death/loot: no megaBossOnDeath here; retail awards the zone sliver from Antaeus, not Arch Antaeus.

return entity
