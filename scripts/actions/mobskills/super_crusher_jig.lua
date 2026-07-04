-----------------------------------
-- Super Crusher Jig
-- Mumor II Trust approximation.
-- Source behavior: exclusive physical performance move.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if
        not mob:hasStatusEffect(xi.effect.MUMORS_RADIANCE) or
        mob:getLocalVar('MUMOR_II_FEVER_STEP') ~= 1
    then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params =
    {
        numHits = 2,
        ftpMod = { 2.0, 2.5, 3.0 },
        str_wsc = 0.4,
        dex_wsc = 0.4,
        attackType = xi.attackType.PHYSICAL,
        damageType = xi.damageType.BLUNT,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_2,
    }

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    mob:setLocalVar('MUMOR_II_FEVER_STEP', 2)

    return info.damage
end

return mobskillObject