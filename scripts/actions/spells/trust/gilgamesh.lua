-----------------------------------
-- Trust: Gilgamesh
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

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.HASSO } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.THIRD_EYE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 40 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SEKKANOKI }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 95 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HAGAKURE }, 180)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 10 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3436 }) -- Tachi: Goten
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3437 }) -- Tachi: Kasha
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3434 }) -- Tachi: Kamai
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3435 }) -- Iainuki

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
