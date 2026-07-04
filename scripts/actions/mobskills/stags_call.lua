-----------------------------------
-- Stag's Call
-- Excenmille (S) Trust TP move.
-- Source notes: AoE party buff with Haste, Attack Boost, and Magic Attack Boost.
-- AoE/party targeting is controlled by mob_skills.sql.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    mob:messageBasic(xi.msg.basic.READIES_WS, 0, skill:getID())
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    target:addStatusEffect(xi.effect.HASTE, { power = 1500, duration = 180, tick = 0, origin = mob })
    target:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 15, duration = 180, tick = 0, origin = mob })
    target:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, { power = 15, duration = 180, tick = 0, origin = mob })

    skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT)
    return xi.effect.HASTE
end

return mobskillObject