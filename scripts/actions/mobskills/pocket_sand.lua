-----------------------------------
-- Pocket Sand
-- Trust: Chacharoon
-- Description: Deals earth damage. Additional effect: Blindness.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    params.mobHPMultiplier = 1
    params.includemab      = true
    params.element         = xi.element.EARTH
    params.damageType      = xi.damageType.EARTH
    params.attackType      = xi.attackType.MAGICAL
    params.shadowBehavior  = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    params.fTP             = { 1.5, 1.5, 1.5 }

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        if info.damage > 0 then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 30, 0, 120)
        end
    end

    return info.damage
end

return mobskillObject
