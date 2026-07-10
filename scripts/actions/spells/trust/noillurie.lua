-----------------------------------
-- Trust: Noillurie
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

    -- Source notes: MP+65%, Auto Refresh, Double Attack, Hasso, Third Eye,
    -- Meditate, Sekkanoki, Cure III/IV at low HP, and a 2000 TP
    -- Yukikaze > Gekko > Kasha > Kaiten sequence.
    mob:addMod(xi.mod.MPP, 65)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:addMod(xi.mod.REFRESH, 3)

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.HASSO } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.c.NOT_STATUS, xi.effect.THIRD_EYE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.TP_LT, 1000 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SEKKANOKI })

    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Approximation: current Trust TP helper cannot force the exact retail
    -- four-step sequence, so she saves TP and favors highest available GK WS.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
