-----------------------------------
-- Area: Talacca Cove
--  Mob: Arrapago Leech (fished up)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
end

return entity
