-----------------------------------
-- Trust: Balamor
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
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 1098)

    -- Dark magic: Balamor spell list 396 contains Absorb spells.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.STR_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_STR }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.DEX_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_DEX }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.VIT_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_VIT }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.AGI_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_AGI }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.INT_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_INT }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.MND_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_MND }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.CHR_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_CHR }, 60)

    -- Balamor special mob skills.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.MS, ai.s.SPECIFIC, 3620 }, 60) -- Last Laugh
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1750 }, { ai.r.MS, ai.s.SPECIFIC, 3619 }, 50) -- Setting the Stage
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1250 }, { ai.r.MS, ai.s.SPECIFIC, 3618 }, 40) -- Regurgitated Swarm
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3617 }, 35) -- Feast of Arrows
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
