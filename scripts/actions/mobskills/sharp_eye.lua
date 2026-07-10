-----------------------------------
-- Sharp Eye
-- Trust: Chacharoon
-- Description: Inflicts Weight/Gravity-style movement down and Defense Down.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local weightMsg = xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.WEIGHT, 50, 0, 60)
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 25, 0, 60)

    skill:setMsg(weightMsg)
    return xi.effect.WEIGHT
end

return mobskillObject
