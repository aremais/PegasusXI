-----------------------------------
-- Trust: Lion
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

    -- Source target: THF/THF dagger Trust.
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)
    mob:addMod(xi.mod.GILFINDER, 1)

    local grapeshot = 3198

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_WS, 0 } }, { ai.r.WS, ai.s.SPECIFIC, grapeshot }, 15)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_MS, 0 } }, { ai.r.WS, ai.s.SPECIFIC, grapeshot }, 15)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_JA, 0 } }, { ai.r.WS, ai.s.SPECIFIC, grapeshot }, 15)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.CASTING_MA, 0 } }, { ai.r.WS, ai.s.SPECIFIC, grapeshot }, 15)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3199 }, 30) -- Pirate Pummel
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3198 }, 30) -- Grapeshot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3200 }, 30) -- Powder Keg
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3201 }, 30) -- Walk the Plank

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject