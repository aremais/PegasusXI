-----------------------------------
-- Trust: Kupofried
-- Passive aura: grants EXP/CP bonus to nearby party members
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
    mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.KUPOFRIED_AURA, subPower = 20, tier = xi.auraTarget.ALLIES, flag = xi.effectFlag.AURA })
    mob:setAutoAttackEnabled(false)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
