-----------------------------------
-- Chomp Rush
-- Family: Raptor
-- Description: Deals damage in a threefold attack to a single target. Additional Effect: Slow
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 3
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        local tp = skill:getTP()
        local duration

        if tp >= 2000 then
            duration = 120 -- 2 minutes
        elseif tp >= 1000 then
            duration = 90  -- 1.5 minutes
        else
            duration = 60  -- 1 minute
        end

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 1250, 0, duration) -- 25% Slow
    end

    return info.damage
end

return mobskillObject
