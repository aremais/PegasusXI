-----------------------------------
-- Area: Full Moon Fountain
--  Mob: Carbuncle Prime
-- Involved in: Waking the Beast HTBF
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
    mob:addImmunity(xi.immunity.SILENCE)
    mob:addImmunity(xi.immunity.PARALYZE)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.BLIND)
    mob:addImmunity(xi.immunity.GRAVITY)
end

entity.onMobSpawn = function(mob)
    -- Carbuncle Prime does not have UDMGPHYS like other elemental primes.
    mob:setMod(xi.mod.UDMGMAGIC, -2000)
end

entity.onMobMobskillChoose = function(mob, target, skillId)
    if math.random(1, 20) == 1 then
        return 911
    else
        return ({ 907, 908, 909, 910 })[math.random(1, 4)]
    end
end

return entity
