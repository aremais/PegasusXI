-----------------------------------
-- Trust: Lilisette
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

    -- Source target: DNC dagger Trust; her abilities are modeled as TP moves.
    mob:addMod(xi.mod.TRIPLE_ATTACK, 5)
    mob:addMod(xi.mod.STORETP, 10)

    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 35 }, { ai.c.HPP_LT, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2447 }, 30) -- Vivifying Waltz
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 25 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2446 }, 90) -- Rousing Samba
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2443 }, 120) -- Sensual Dance

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2442 }, 30) -- Thorned Stance
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2444 }, 30) -- Dancer's Fury
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 2445 }, 30) -- Whirling Edge

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
