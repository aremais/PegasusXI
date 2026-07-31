-----------------------------------
-- Area: Escha - Ru'Aun
--  Mob: Naga Raja
-----------------------------------
require('scripts/globals/domain_invasion')

---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.awardDomainPoints(mob, xi.title.NAGA_RAJA_NULLIFIER)
end

return entity
