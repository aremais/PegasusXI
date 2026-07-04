-----------------------------------
-- Trust: Iroha II
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

    -- Source target: WHM/SAM Naginata/Polearm Trust with Protectra V, Shellra V, Flare II MB, and Rise from Ashes.
    mob:addMod(xi.mod.HPP, -5)
    mob:addMod(xi.mod.MPP, 250)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)

    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.NOT_STATUS, xi.effect.PROTECT } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECTRA_V })
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.NOT_STATUS, xi.effect.SHELL } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELLRA_V })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLARE_II })

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.THIRD_EYE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE }, 30)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.HASSO } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 30 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE }, 180)

    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3738 }, 30) -- Rise from Ashes
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3738 }, 30) -- Rise from Ashes
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 75 }, { ai.c.HPP_LT, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3738 }, 30) -- Rise from Ashes approximation

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 40 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3733 }, 30) -- Amatsu: Kyori
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3734 }, 30) -- Amatsu: Hanadoki
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3737 }, 30) -- Amatsu: Suien
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3736 }, 30) -- Amatsu: Gachirin

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject