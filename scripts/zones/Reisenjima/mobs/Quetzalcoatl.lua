-----------------------------------
-- Area: Reisenjima
--  Mob: Quetzalcoatl
-----------------------------------
require('scripts/globals/domain_invasion')

---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.awardDomainPoints(mob, xi.title.QUETZALCOATL_PLUCKER)
end

return entity
