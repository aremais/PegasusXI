-----------------------------------
-- Rhinowrecker
-- Family: Beetle
-- Description: Deals physical damage to all enemies in a fan-shaped area in front of pet.
--              Additional Effect: Defense Down. Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE
-- Skillchain: Fusion / Transfixion
-- TODO: Verify fTP and Defense Down power/duration from retail captures.
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
    params.fTP            = { 2.5, 3.0, 3.5 } -- TODO: Verify from retail captures
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 25, 0, 60) -- TODO: Verify power/duration
    end

    return info.damage
end

return mobskillObject
