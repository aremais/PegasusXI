-----------------------------------
-- Trust: Maat (UC)
-----------------------------------
require("scripts/globals/trust")
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.MAAT_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail target: Unity MNK/WAR Trust.
    -- Lax custom tuning: make the Unity version clearly stronger than normal Maat
    -- while preserving his role as a hand-to-hand attacker.
    mob:addMod(xi.mod.COUNTER, 20)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 15)
    mob:addMod(xi.mod.KICK_ATTACK_RATE, 30)
    mob:addMod(xi.mod.STORETP, 10)

    -- MNK/WAR job ability behavior.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 35 }, { ai.c.HPP_LT, 50 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAKRA }, 180)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 45 }, { ai.c.NOT_STATUS, xi.effect.COUNTERSTANCE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.COUNTERSTANCE }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 88 }, { ai.c.NOT_STATUS, xi.effect.IMPETUS } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.IMPETUS }, 300)

    -- Lax custom WS mix.
    -- Hollow Smite remains the signature UC weapon skill and is checked before
    -- the higher-level fallback WS entries.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 2000 } }, { ai.r.WS, ai.s.SPECIFIC, 3496 }, 30) -- Hollow Smite

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 1500 } }, { ai.r.WS, ai.s.SPECIFIC, 3417 }, 30) -- Asuran Fists
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1500 } }, { ai.r.WS, ai.s.SPECIFIC, 3416 }, 30) -- Dragon Kick
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1250 } }, { ai.r.WS, ai.s.SPECIFIC, 3415 }, 30) -- Howling Fist
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 10 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3414 }, 30) -- One-Ilm Punch
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3413 }, 30) -- Combo
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
