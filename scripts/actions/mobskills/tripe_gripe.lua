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

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    mob:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 25, duration = 60, origin = mob })

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, 30))

    return xi.effect.AMNESIA
end

return mobskillObject
