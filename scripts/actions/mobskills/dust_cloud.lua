-----------------------------------
-- Dust Cloud
-- Family: Rabbit
-- Description: Deals Earth elemental damage to enemies in a fan-shaped area.
--              Additional Effect: Blind. Damage varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE
-- Skillchain: N/A
-- TODO: Verify fTP and Blind power/duration from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 1.5, 2.0, 2.5 } -- TODO: Verify from retail captures
    params.element        = xi.element.EARTH
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.EARTH
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 30, 0, 120) -- TODO: Verify power/duration
    end

    return info.damage
end

return mobskillObject
