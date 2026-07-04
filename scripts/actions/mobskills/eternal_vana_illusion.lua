-----------------------------------
-- Eternal Vana Illusion
-- Mumor II Trust approximation.
-- Source behavior: aura sequence performance move.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if
        not mob:hasStatusEffect(xi.effect.MUMORS_RADIANCE) or
        mob:getLocalVar('MUMOR_II_FEVER_STEP') ~= 2
    then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local skillParams =
    {
        numHits = 1,
        multiplier = 3.25,
        tp150 = 3.5,
        tp300 = 4.0,
        damageType = xi.damageType.LIGHT,
        element = xi.element.LIGHT,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
    }

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, skillParams)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    mob:setLocalVar('MUMOR_II_FEVER_STEP', 3)

    return info.damage
end

return mobskillObject