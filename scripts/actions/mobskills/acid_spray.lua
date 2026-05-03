-----------------------------------
-- Acid Spray
-- Family: Spider
-- Description: Deals Water elemental damage to a target.
--              Additional Effect: Poison (31 damage/tic) for 3 minutes.
--              Damage varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Single target
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
    params.fTP            = { 1.0, 1.5, 2.0 } -- TODO: Verify from retail captures
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.POISON, 31, 3, 180) -- 31 dmg/tic, 3 min
    end

    return info.damage
end

return mobskillObject
