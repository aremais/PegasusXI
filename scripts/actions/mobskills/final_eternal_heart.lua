-----------------------------------
-- Final Eternal Heart
-- Mumor II Trust approximation.
-- Source behavior: final AoE finisher after Firesday Night Fever sequence.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if
        not mob:hasStatusEffect(xi.effect.MUMORS_RADIANCE) or
        mob:getLocalVar('MUMOR_II_FEVER_STEP') ~= 3
    then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local skillParams =
    {
        numHits = 1,
        multiplier = 4.0,
        tp150 = 4.5,
        tp300 = 5.0,
        damageType = xi.damageType.LIGHT,
        element = xi.element.LIGHT,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
    }

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, skillParams)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    -- Retail note: Firesday Night Fever ends after Final Eternal Heart.
    -- Clear the aura even if this is the finishing blow, avoiding the retail stuck-aura glitch.
    mob:delStatusEffect(xi.effect.MUMORS_RADIANCE)
    mob:delStatusEffect(xi.effect.MAGIC_ATK_BOOST)
    mob:delStatusEffect(xi.effect.REGAIN)
    mob:setLocalVar('MUMOR_II_FEVER_STEP', 0)

    return info.damage
end

return mobskillObject
