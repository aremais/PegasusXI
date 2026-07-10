-----------------------------------
-- Descension
-- Trust: Arciela II
-- Notes: Functional Trust approximation. Grants a short defensive magic boost.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT)
    mob:addStatusEffect(xi.effect.MAGIC_DEF_BOOST, 20, 0, 120)
    return xi.effect.MAGIC_DEF_BOOST
end

return mobskillObject
