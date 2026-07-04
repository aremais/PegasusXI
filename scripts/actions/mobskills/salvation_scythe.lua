-----------------------------------
-- Salvation Scythe
-- D. Shantotto Trust approximation.
-- Source behavior: exclusive scythe weaponskill.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params =
    {
        numHits = 1,
        ftpMod = { 3.0, 3.5, 4.0 },
        str_wsc = 0.4,
        int_wsc = 0.4,
        attackType = xi.attackType.PHYSICAL,
        damageType = xi.damageType.SLASHING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
    }

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
