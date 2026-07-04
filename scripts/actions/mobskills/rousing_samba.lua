-----------------------------------
-- Rousing Samba
-- Lilisette / Lilisette II support TP move.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    target:addStatusEffect(xi.effect.MIGHTY_STRIKES, 1, 0, 30)
    return 0
end

return mobskillObject