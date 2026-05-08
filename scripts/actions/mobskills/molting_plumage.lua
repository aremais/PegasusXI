-----------------------------------
-- Molting Plumage
-- Family: Tulfaire
-- Description: Deals Wind elemental damage to enemies in a fan-shaped area.
--              Additional Effect: Dispel (Light-based). Area of effect varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE (range varies with TP — controlled via SQL/skill data)
-- Skillchain: N/A
-- TODO: Verify fTP from retail captures.
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
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Dispel (Light-based): removes one beneficial effect
        target:dispelStatusEffect(xi.dispelType.BENEFICIAL)
    end

    return info.damage
end

return mobskillObject
