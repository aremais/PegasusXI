-----------------------------------
-- Trust: Cornelia
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NON_COMBAT)

    -- Cornelia is an incorporeal passive aura Trust.
    -- Retail aura: Haste +20%, Accuracy +30, Ranged Accuracy +30, Magic Accuracy +30 at Lv99.
    mob:addMod(xi.mod.AURA_SIZE, 600)

    mob:addStatusEffect(xi.effect.COLURE_ACTIVE,
    {
        power = 6,
        origin = mob,
        tick = 3,
        subType = xi.effect.TRUST_AURA_HASTE,
        subPower = mob:getMainLvl(),
        subIcon = xi.effect.GEO_HASTE,
        tier = xi.auraTarget.ALLIES,
        flag = xi.effectFlag.AURA,
    })

    if mob.setUnkillable then
        mob:setUnkillable(true)
    end

    mob:setAutoAttackEnabled(false)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    -- Cornelia is incorporeal and should not die.
end

return spellObject
