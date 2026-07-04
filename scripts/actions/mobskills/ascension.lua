-----------------------------------
-- Ascension
-- Trust: Arciela II
-- Notes: Functional Trust approximation. Grants a short offensive magic boost.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT)
    mob:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, 20, 0, 120)
    return xi.effect.MAGIC_ATK_BOOST
end

return mobskillObject
