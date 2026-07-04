-----------------------------------
-- Trust: Luzaf
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

    -- Source target: COR/NIN ranged Trust. Does not use Phantom Roll.
    mob:addMod(xi.mod.RACC, 50)
    mob:addMod(xi.mod.RATT, 25)
    mob:addMod(xi.mod.STORETP, 15)
    mob:addMod(xi.mod.TRIPLE_SHOT_RATE, 10)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3252 }, 30) -- Bisection
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3253 }, 30) -- Leaden Salute
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 70 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3254 }, 30) -- Akimbo Shot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3255 }, 30) -- Grisly Horizon

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 }, 10)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject