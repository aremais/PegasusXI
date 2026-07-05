-----------------------------------
-- Sensual Dance
-- Lilisette / Lilisette II support TP move.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    target:addStatusEffect(xi.effect.ATTACK_BOOST, 15, 0, 60)
    target:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, 15, 0, 60)
    return 0
end

return mobskillObject
