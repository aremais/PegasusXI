-----------------------------------
-- Sharp Eye
-- Inflicts Gravity/Weight on targets in front of Chacharoon.
-----------------------------------
require("scripts/globals/mobskills")
require("scripts/globals/status")
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.WEIGHT, 50, 0, 60))

    return xi.effect.WEIGHT
end

return mobskillObject