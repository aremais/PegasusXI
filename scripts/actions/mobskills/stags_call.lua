-----------------------------------
-- Stag's Call
-- Trust: Excenmille (S)
-- AoE party buff: Haste, Attack Boost, Magic Attack Boost
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local duration = 180
    local partyMembers = mob:getParty()

    if partyMembers then
        for _, member in ipairs(partyMembers) do
            if
                mob:checkDistance(member) <= 6 and
                member:isAlive()
            then
                member:addStatusEffect(xi.effect.HASTE, { power = 1500, duration = duration, origin = mob })
                member:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 15, duration = duration, origin = mob })
                member:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, { power = 15, duration = duration, origin = mob })
            end
        end
    end

    skill:setMsg(xi.msg.basic.USES)

    return xi.effect.HASTE
end

return mobskillObject
