-----------------------------------
-- Trust: Arciela II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ARCIELA_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 1132)

    -- Party buffs
    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.PROTECT },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })

    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.SHELL },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })

    mob:addGambit(ai.t.MELEE,
        { ai.c.NOT_STATUS, xi.effect.HASTE },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })

    mob:addGambit(ai.t.RANGED,
        {
            { ai.c.NOT_STATUS, xi.effect.FLURRY_II },
            { ai.c.NOT_STATUS, xi.effect.HASTE },
        },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FLURRY })

    mob:addGambit(ai.t.CASTER,
        {
            { ai.c.NOT_STATUS, xi.effect.REFRESH },
            { ai.c.NOT_STATUS, xi.effect.SUBLIMATION_ACTIVATED },
            { ai.c.NOT_STATUS, xi.effect.SUBLIMATION_COMPLETE },
        },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH })

    mob:addGambit(ai.t.TANK,
        { ai.c.NOT_STATUS, xi.effect.REFRESH },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH })

    -- Enfeebles
    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.SLOW },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW },
        60)

    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.PARALYSIS },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE },
        60)

    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.ADDLE },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ADDLE },
        60)

    mob:addGambit(ai.t.TARGET,
        { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DISPEL })

    -- Single-target elemental nukes
    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRE },
        30)

    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BLIZZARD },
        30)

    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.AERO },
        30)

    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.STONE },
        30)

    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDER },
        30)

    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.WATER },
        30)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
