-----------------------------------
-- Trust: Makki-Chebukki
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

    -- Retail/source notes: ranged fighter who keeps distance, uses WS at
    -- 2000 TP, does not try to skillchain, and may be inactive on Lightsday.
    -- Lightsday inactivity is held until we add a safe day-check pattern.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BARRAGE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BARRAGE })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHARPSHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SHARPSHOT })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.FLASHY_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FLASHY_SHOT })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })

    mob:setAutoAttackEnabled(false)

    -- BGWiki notes MP+100%, Store TP-40, Ranged Attacks: TP+100%.
    -- MP+100% is represented directly; the TP+100% behavior remains an
    -- approximation through current ranged attack TP gain.
    mob:addMod(xi.mod.MPP, 100)
    mob:addMod(xi.mod.STORETP, -40)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)

    -- Approximation for "uses weapon skills at 2000 TP and does not try to skillchain."
    -- RANDOM keeps him from deliberately choosing open/close behavior.
    mob:setTrustTPSkillSettings(ai.tp.RANDOM, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
