-----------------------------------
-- Shining Summer Samba
-- Mumor II Trust approximation.
-- Source behavior: exclusive magical damage performance move.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local skillParams =
    {
        numHits = 1,
        multiplier = 2.5,
        tp150 = 2.75,
        tp300 = 3.0,
        damageType = xi.damageType.FIRE,
        element = xi.element.FIRE,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
    }

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, skillParams)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject