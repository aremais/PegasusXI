-----------------------------------
-- Dignified Awe
-- Trust: Arciela II
-- Notes: Functional Trust approximation. Grants party attack and magic attack boosts.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local duration = 180
    local power    = 15

    skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT)

    mob:timer(100, function(mobArg)
        local party = mobArg:getPartyWithTrusts()

        for _, member in ipairs(party) do
            if member:isAlive() and member:checkDistance(mobArg) <= 10 then
                member:addStatusEffect(xi.effect.ATTACK_BOOST, power, 0, duration)
                member:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, power, 0, duration)
            end
        end
    end)

    return xi.effect.ATTACK_BOOST
end

return mobskillObject
