-----------------------------------
-- Trust: Lhe Lhangavo
-----------------------------------
require('scripts/globals/trust')
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Source target: MNK/WAR bare-hand Trust.
    mob:addMod(xi.mod.COUNTER, 10)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:addMod(xi.mod.KICK_ATTACK_RATE, 10)

    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 5 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }, 30)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.DODGE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DODGE }, 180)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 41 }, { ai.c.HPP_LT, 75 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAKRA }, 180)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 88 }, { ai.c.NOT_STATUS, xi.effect.IMPETUS } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.IMPETUS }, 300)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 10 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 4 }) -- Backhand Blow
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 5 }) -- Raging Fists
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 8 }) -- Dragon Kick
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 9 }) -- Asuran Fists

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
