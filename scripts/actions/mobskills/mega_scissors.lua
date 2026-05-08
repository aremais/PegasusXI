-----------------------------------
-- Mega Scissors
-- Family: Barnacled Crab
-- Description: Deals physical damage to a target. Critical hit rate varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 2 shadows
-- Range: Single target
-- Skillchain: Gravitation / Scission
-- TODO: Verify fTP from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage      = mob:getWeaponDmg()
    params.numHits         = 2
    params.fTP             = { 1.5, 2.0, 2.5 } -- TODO: Verify from retail captures
    params.attackType      = xi.attackType.PHYSICAL
    params.damageType      = xi.damageType.SLASHING
    params.shadowBehavior  = xi.mobskills.shadowBehavior.NUMSHADOWS_2
    params.canCrit         = true
    params.criticalChance  = { 0.25, 0.50, 0.75 } -- Critical hit rate varies with TP

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
