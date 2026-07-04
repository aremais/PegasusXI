-----------------------------------
-- Vortex
-- Family: Eald'narche / Trust: Mildaurion
-- Description: Magical Wind damage. Additional Effect: Terror and Bind.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.fTP            = { 2.0, 2.0, 2.0 } -- Approximation; exact retail fTP not captured.
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3 -- TODO: confirm exact shadow behavior.

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- TODO: Capture exact retail durations.
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, 9)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIND, 1, 0, 30)

        -- Source notes include enmity reset behavior.
        mob:resetEnmity(target)
    end

    return info.damage
end

return mobskillObject
