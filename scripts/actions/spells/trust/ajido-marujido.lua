-----------------------------------
-- Trust: Ajido-Marujido
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.SHANTOTTO] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.STAR_SIBYL] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.KORU_MORU] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.KARAHA_BARUHA] = xi.trust.messageOffset.TEAMWORK_4,
        [xi.magic.spell.SEMIH_LAFIHNA] = xi.trust.messageOffset.TEAMWORK_5,
    })

    -- Retail: Cure Potency Bonus +25%.
    mob:addMod(xi.mod.CURE_POTENCY, 25)

    -- Retail: Ajido-Marujido prioritizes Dispel over elemental magic.
    -- Branch-safe approximation: use Dispel only when common removable buffs are present.
    mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DISPEL }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DISPEL }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DISPEL }, 30)

    -- Magic burst if available.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })

    -- Emergency Cure I-IV only; spell list enforces the Cure IV cap.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Retail spell kit includes Paralyze and Slow.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)

    -- Offensive magic fallback. The DB spell list contains only single-target nukes I-V.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 60)

    -- Ajido does not chase into melee range.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
