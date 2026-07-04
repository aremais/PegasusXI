-----------------------------------
-- Illustrious Aid
-- Trust: Arciela
-- Description: Restores HP in an area of effect.
-- Notes: Branch-safe Trust approximation based on documented retail behavior.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local function getArcielaPartyTargets(mob)
    local party = nil
    local master = mob:getMaster()

    if master ~= nil then
        party = master:getPartyWithTrusts()
    end

    if party ~= nil then
        return party
    end

    local fallback = {}

    if master ~= nil then
        table.insert(fallback, master)
    end

    table.insert(fallback, mob)

    return fallback
end
mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local amount = 300 + mob:getMainLvl() * 5
    local healed = 0
    local targets = getArcielaPartyTargets(mob)

    for _, member in pairs(targets) do
        if
            member ~= nil and
            member:isAlive() and
            member:getHP() > 0 and
            member:getHPP() < 100 and
            member:checkDistance(mob) <= 10
        then
            member:addHP(amount)
            member:wakeUp()
            healed = healed + amount
        end
    end

    skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)

    return 0
end

return mobskillObject
