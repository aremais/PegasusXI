-----------------------------------
-- Area: Escha - Zi'Tah
--  Mob: Azi Dahaka
-----------------------------------
require('scripts/globals/domain_invasion')

---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.awardDomainPoints(mob, xi.title.AZI_DAHAKA_ANNIHILATOR)
end

return entity
