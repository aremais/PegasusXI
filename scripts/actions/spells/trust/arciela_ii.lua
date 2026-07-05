-----------------------------------
-- Trust: Arciela II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ARCIELA)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Offensive/support Trust approximation based on documented Arciela II behavior:
    -- Haste/Haste II, Refresh/Refresh II, Flurry/Flurry II, Slow/Paralyze enfeebles,
    -- Dispel/Addle, elemental magic from spell list 426, Regain, and unique TP moves.

    mob:addMod(xi.mod.REGAIN, 30)
    mob:addMod(xi.mod.FASTCAST, 50)

    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.CASTER, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH })

    mob:addGambit(ai.t.RANGED, {
        { ai.c.NOT_STATUS, xi.effect.FLURRY_II },
        { ai.c.NOT_STATUS, xi.effect.HASTE },
    }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FLURRY })

    mob:addGambit(ai.t.TARGET, { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DISPEL })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.ADDLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ADDLE }, 60)

    -- Safe elemental fallback. Spell list 426 level-gates available tiers.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRE }, 30)

    -- Uses confirmed Arciela II unique TP moves from skill list 1132.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
