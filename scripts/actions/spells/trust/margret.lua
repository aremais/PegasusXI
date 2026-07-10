-----------------------------------
-- Trust: Margret
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

    -- Retail/source notes: ranged fighter who keeps distance, supports TP moves
    -- with ranged job abilities, uses WS at 2000 TP, and does not try to skillchain.
    -- Low-HP enemy WS/JA holding is held until a safe HP-threshold gambit pattern exists.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BARRAGE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BARRAGE })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHARPSHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SHARPSHOT })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DOUBLE_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DOUBLE_SHOT })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DECOY_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DECOY_SHOT })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })

    mob:setAutoAttackEnabled(false)

    -- BGWiki notes Treasure Hunter, Store TP+40, and Ranged Attacks: TP+100%.
    -- TP+100% remains an approximation through current ranged attack TP gain.
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)
    mob:addMod(xi.mod.STORETP, 40)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)

    -- Approximation for "uses weapon skills at 2000 TP and does not try to skillchain."
    mob:setTrustTPSkillSettings(ai.tp.RANDOM, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
