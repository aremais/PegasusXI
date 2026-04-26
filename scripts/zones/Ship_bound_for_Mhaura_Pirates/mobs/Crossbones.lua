-----------------------------------
-- Area: Ship bound for Mhaura Pirates
--  Mob: Crossbones
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
end

entity.onMobDeath = function(mob, player, optParams)
    local zone = mob:getZone()
    if xi.pirates.isPirateMobWaveActive(zone) then
        mob:setRespawnTime(math.random(30, 75))
    end
end

return entity
