-----------------------------------
-- Trust: Najelith
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

    -- Retail/source notes: RNG/RNG ranged fighter. Holds position after engaging,
    -- performs ranged attacks, can melee if already in melee range, and holds
    -- TP until about 1500 to close skillchains.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BARRAGE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BARRAGE })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DOUBLE_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DOUBLE_SHOT })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })

    -- BGWiki notes enhanced Critical Hit Rate and melee/ranged attacks TP+100%.
    -- TP+100% remains approximated through current TP mechanics.
    mob:addMod(xi.mod.CRITHITRATE, 10)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
