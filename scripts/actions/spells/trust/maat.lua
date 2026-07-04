-----------------------------------
-- Trust: Maat
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

    -- Retail/source target: MNK/THF hand-to-hand Trust.
    mob:addMod(xi.mod.COUNTER, 10)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:addMod(xi.mod.KICK_ATTACK_RATE, 10)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)

    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 75 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANTRA }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 75 }, { ai.c.NOT_STATUS, xi.effect.FORMLESS_STRIKES } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FORMLESS_STRIKES }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 79 }, { ai.c.NOT_STATUS, xi.effect.PERFECT_COUNTER } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PERFECT_COUNTER }, 60)

    -- Explicit 1000 TP WS gates. Do not use mob:setTrustTPSkillSettings on this branch.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3413 }, 30) -- Combo
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 10 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3414 }, 30) -- One-Ilm Punch
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3415 }, 30) -- Howling Fist
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3416 }, 30) -- Dragon Kick
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3417 }, 30) -- Asuran Fists
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3263 }, 30) -- Bear Killer

    mob:addListener("WEAPONSKILL_USE", "MAAT_BEAR_KILLER_MESSAGE", function(mobArg, targetArg, skill, tp, action, damage)
        if skill:getID() == 3263 then
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
        end
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
