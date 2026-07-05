-----------------------------------
-- Naakual's Vengeance
-- Trust: Arciela II
-- Notes: Functional Trust approximation. Restores HP/MP to Arciela II and nearby party members.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local hpPower = math.floor(500 + mob:getMainLvl() * 6)
    local mpPower = math.floor(100 + mob:getMainLvl() * 2)

    skill:setMsg(xi.msg.basic.SKILL_RECOVERS_HP)

    mob:timer(100, function(mobArg)
        local party = mobArg:getPartyWithTrusts()

        for _, member in ipairs(party) do
            if member:isAlive() and member:checkDistance(mobArg) <= 10 then
                member:addHP(hpPower)
                member:addMP(mpPower)
                member:wakeUp()
            end
        end
    end)

    return hpPower
end

return mobskillObject
