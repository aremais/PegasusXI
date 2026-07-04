-----------------------------------
-- Area: Talacca Cove
--  Mob: Wootzshell (fished up)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
end

return entity
