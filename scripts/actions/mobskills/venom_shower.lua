-----------------------------------
-- Venom Shower
-- Family: Barnacled Crab
-- Description: Deals Water elemental damage to enemies in an area of effect.
--              Additional Effect: STR Down. Area of effect varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: AoE (range varies with TP — controlled via SQL/skill data)
-- Skillchain: N/A
-- TODO: Verify fTP and STR Down power/duration from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 1.0, 1.5, 2.0 } -- TODO: Verify from retail captures
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STR_DOWN, 20, 0, 60) -- TODO: Verify power/duration
    end

    return info.damage
end

return mobskillObject
