-----------------------------------
-- Pestilent Plume
-- Family: Acuex
-- Description: Deals Darkness elemental damage in a fan-shaped area.
--              Additional Effects: Plague (-50 TP/tic), Blind (-50 Accuracy),
--              and -25 MDB for 60 seconds. Damage varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE
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
    params.element        = xi.element.DARK
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.DARK
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Additional Effect: Plague (-50 TP/tic) for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 3, 0, 60)

        -- Additional Effect: Blind (-50 Accuracy) for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 50, 0, 60)

        -- Additional Effect: -25 Magic Defense for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAGIC_DEF_DOWN, 25, 0, 60)
    end

    return info.damage
end

return mobskillObject
