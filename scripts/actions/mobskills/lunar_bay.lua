-----------------------------------
-- Lunar Bay
-- Karaha-Baruha Trust special move.
-- Source behavior: dark damage.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params =
    {
        baseDamage = mob:getMainLvl() + 2,
        fTP = { 3.0, 3.0, 3.0 },
        element = xi.element.DARK,
        attackType = xi.attackType.MAGICAL,
        damageType = xi.damageType.DARK,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
        skipMagicBonusDiff = true,
    }

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject