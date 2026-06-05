-----------------------------------
-- Trust: Selh'teus
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

    -- Retail-style Selh'teus:
    -- Regain +50, MP +100%, non-melee support positioning.
    -- Special moves:
    -- xi.mobSkill.LUMINOUS_LANCE_1 = 1508
    -- xi.mobSkill.REJUVENATION_1   = 1509
    -- xi.mobSkill.REVELATION_1     = 1510
    mob:addMod(xi.mod.REGAIN, 50)
    mob:addMod(xi.mod.MPP, 100)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NON_COMBAT)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 1094)
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
