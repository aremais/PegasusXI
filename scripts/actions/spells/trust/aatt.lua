-----------------------------------
-- Trust: AATT
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

    mob:setMobMod(xi.mobMod.SKILL_LIST, 1110)
    mob:setAutoAttackEnabled(true)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)

    -- Reactive Stun
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_WS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_MS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_JA, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.CASTING_MA, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })

    -- Job abilities
    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 180)

    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.LAST_RESORT },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.LAST_RESORT }, 180)

    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.SOULEATER },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.SOULEATER }, 180)

    -- Dark magic upkeep
    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.BIO },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BIO }, 60)

    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.POISON },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.POISON }, 60)

    -- Weapon skills
    mob:addGambit(ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.HIGHEST, 0 }, 8)

    -- General nuking
    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_SC_AVAILABLE, 0 },
        { ai.r.MA, ai.s.BEST_AGAINST_TARGET, 0 }, 30)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
