-----------------------------------
-- Vivifying Waltz
-- Lilisette / Lilisette II support TP move.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local heal = math.floor(target:getMaxHP() * 0.25)
    target:addHP(heal)
    return heal
end

return mobskillObject