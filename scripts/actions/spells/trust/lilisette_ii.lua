-----------------------------------
-- Trust: Lilisette II
-----------------------------------
require("scripts/globals/trust")
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

    -- Source target: DNC dagger Trust with fast TP gain and 2000 TP closer behavior.
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)
    mob:addMod(xi.mod.STORETP, 20)

    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.HPP_LT, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3313 }, 30) -- Vivifying Waltz
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 25 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3312 }, 90) -- Rousing Samba
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3309 }, 120) -- Sensual Dance

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3310 }, 30) -- Dancer's Fury

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject