-----------------------------------
-- Big Scissors
-- Family: Crab
-- Description: Deals physical damage to a single target.
--              Critical hit rate varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 1 shadow
-- Range: Single target
-- Skillchain: Scission
-- Note: Nightmare Crabs ignore shadows.
-- TODO: Nightmare Crab variant — IGNORE_SHADOWS behavior.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.canCrit        = true
    params.criticalChance = { 0.25, 0.50, 0.75 } -- Critical hit rate varies with TP

    -- TODO: Nightmare Crab - IGNORE_SHADOWS

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
