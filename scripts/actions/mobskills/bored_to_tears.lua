-----------------------------------
-- Bored to Tears
-- Ullegore Trust special move.
-- Approximation: terror status effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, 10))

    return xi.effect.TERROR
end

return mobskillObject
