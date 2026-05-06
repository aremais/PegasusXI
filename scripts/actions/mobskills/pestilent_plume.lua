-----------------------------------
-- Pestilent Plume
-- Family: FlyHi
-- Description: Deals physical damage to enemies within a fan-shaped area.
--              Additional Effect: Plague. Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE (14 yalms)
-- Skillchain: Reverberation
-- TODO: Verify fTP, Plague potency/duration, and skillchain from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    local wdmg = mob:getWeaponDmg()
    params.baseDamage     = (wdmg > 0) and wdmg or mob:getMainLvl()
    params.numHits        = 1
    params.fTP            = { 1.5, 2.0, 2.5 } -- TODO: Verify from retail captures
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Additional Effect: Plague for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 3, 0, 60)
    end

    return info.damage
end

return mobskillObject
