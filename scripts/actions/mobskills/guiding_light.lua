-----------------------------------
-- Guiding Light
-- Nearby party members gain attack, defense, magic attack, and magic defense.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power    = 15
    local duration = 30

    xi.mobskills.mobBuffMove(target, xi.effect.ATTACK_BOOST, power, 0, duration)
    xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, power, 0, duration)
    xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_ATK_BOOST, power, 0, duration)

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_DEF_BOOST, power, 0, duration))
    return xi.effect.MAGIC_DEF_BOOST
end

return mobskillObject
