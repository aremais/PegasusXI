-----------------------------------
-- Trust: Ingrid II
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

    -- Source target: WHM/WAR rod/club-style melee caster.
    -- Banish/Holy/Cursna are DB-provided; source says Banish line is used for Magic Burst,
    -- so no free-cast Banish spam gambit is added here.
    mob:addMod(xi.mod.UNDEAD_KILLER, 8)
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)

    -- Approximate source's Banish-vs-Undead bonus through light/divine offensive bias.
    mob:addMod(xi.mod.LIGHT_MAB, 10)

    mob:addGambit(ai.t.PARTY, {
        ai.l.OR({ ai.c.STATUS, xi.effect.CURSE_I }, { ai.c.STATUS, xi.effect.CURSE_II }, { ai.c.STATUS, xi.effect.BANE }, { ai.c.STATUS, xi.effect.DOOM })
    }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BANISH })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MS, ai.s.SPECIFIC, 3646 }, 30) -- Self-Aggrandizement
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MS, ai.s.SPECIFIC, 3646 }, 30) -- Self-Aggrandizement
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MS, ai.s.SPECIFIC, 3646 }, 30) -- Self-Aggrandizement approximation

    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3644 }) -- Ruthlessness
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3645 }) -- Inexorable Strike
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 164 }) -- Moonlight
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3647 }) -- Merciless Strike

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject