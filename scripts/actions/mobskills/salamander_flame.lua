-----------------------------------
-- Salamander Flame
-- Description: Deals fire damage in an area of effect. Additional effect: Dia III.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 2.75, 3.00, 3.25 }
    params.element        = xi.element.FIRE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Dia III-style approximation: 30 seconds.
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DIA, 15, 3, 30)
    end

    return info.damage
end

return mobskillObject
