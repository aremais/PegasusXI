-----------------------------------
-- Trust: Lion II
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
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN, {
        [xi.magic.spell.ZEID] = xi.trust.messageOffset.TEAMWORK_1,
    })

    -- Source target: THF/NIN dagger Trust with Utsusemi and Lion II unique TP moves.
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)
    mob:addMod(xi.mod.GILFINDER, 1)

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 12 }, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE } }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI }, 30)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_WS, 0 } }, { ai.r.WS, ai.s.SPECIFIC, 3491 }, 15) -- Grapeshot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_MS, 0 } }, { ai.r.WS, ai.s.SPECIFIC, 3491 }, 15) -- Grapeshot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.READYING_JA, 0 } }, { ai.r.WS, ai.s.SPECIFIC, 3491 }, 15) -- Grapeshot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.CASTING_MA, 0 } }, { ai.r.WS, ai.s.SPECIFIC, 3491 }, 15) -- Grapeshot

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3492 }, 30) -- Pirate Pummel
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3491 }, 30) -- Grapeshot
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3493 }, 30) -- Powder Keg
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3494 }, 30) -- Walk the Plank

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
