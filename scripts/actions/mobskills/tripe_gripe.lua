-----------------------------------
-- Tripe Gripe
-- Inflicts Amnesia on targets in a fan-shaped area and grants Attack Boost to Chacharoon.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    mob:addStatusEffect(xi.effect.ATTACK_BOOST, 25, 0, 60)

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, 30))

    return xi.effect.AMNESIA
end

return mobskillObject
