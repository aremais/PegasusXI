-----------------------------------
-- Trust: Elivira
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

    -- Retail notes: RNG/WAR ranged fighter. Holds position after engaging,
    -- can melee if already in range, and tends to WS at 1000 TP while closing
    -- skillchains when possible.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })

    -- BGWiki notes Store TP-30 and TP+100% for melee/ranged attacks.
    -- Store TP is represented directly; the TP+100% behavior remains an approximation
    -- through normal ranged attack TP gain until a dedicated Trust TP override exists.
    mob:addMod(xi.mod.STORETP, -30)

    -- Keep her as a ranged-position Trust without disabling melee outright.
    -- This lets her still melee if spawned/engaged in melee range, matching source notes.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
