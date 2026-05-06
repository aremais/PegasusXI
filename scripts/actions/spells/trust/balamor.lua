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

    -- Balamor special mob skills.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1500 }, { ai.r.MS, ai.s.SPECIFIC, 3620 }, 30) -- Last Laugh
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1250 }, { ai.r.MS, ai.s.SPECIFIC, 3619 }, 25) -- Setting the Stage
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3618 }, 20) -- Regurgitated Swarm
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3617 }, 15) -- Feast of Arrows
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
