-----------------------------------
-- Guiding Light
-- Trust: Arciela
-- Description: Grants attack, defense, magic attack, and magic defense bonuses.
-- Notes: Functional Trust approximation based on documented retail behavior.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local duration = 180
    local power    = 15

    skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)

    local function addGuidingLightMod(memberArg, modId, amount)
        if modId ~= nil then
            memberArg:addMod(modId, amount)
        end
    end

    local function delGuidingLightMod(memberArg, modId, amount)
        if modId ~= nil then
            memberArg:delMod(modId, amount)
        end
    end

    local function applyGuidingLightBuff(member)
        local previousPower = member:getLocalVar('ArcielaGuidingLightPower')
        local expireTime = GetSystemTime() + duration

        if previousPower > 0 then
            delGuidingLightMod(member, xi.mod.ATT, previousPower)
            delGuidingLightMod(member, xi.mod.DEF, previousPower)
            delGuidingLightMod(member, xi.mod.MATT, previousPower)
            delGuidingLightMod(member, xi.mod.MDEF, previousPower)
        end

        addGuidingLightMod(member, xi.mod.ATT, power)
        addGuidingLightMod(member, xi.mod.DEF, power)
        addGuidingLightMod(member, xi.mod.MATT, power)
        addGuidingLightMod(member, xi.mod.MDEF, power)

        member:setLocalVar('ArcielaGuidingLightPower', power)
        member:setLocalVar('ArcielaGuidingLightExpires', expireTime)

        member:timer(duration * 1000, function(memberArg)
            if memberArg == nil then
                return
            end

            local storedPower = memberArg:getLocalVar('ArcielaGuidingLightPower')
            local storedExpire = memberArg:getLocalVar('ArcielaGuidingLightExpires')

            if storedPower > 0 and storedExpire <= GetSystemTime() then
                delGuidingLightMod(memberArg, xi.mod.ATT, storedPower)
                delGuidingLightMod(memberArg, xi.mod.DEF, storedPower)
                delGuidingLightMod(memberArg, xi.mod.MATT, storedPower)
                delGuidingLightMod(memberArg, xi.mod.MDEF, storedPower)

                memberArg:setLocalVar('ArcielaGuidingLightPower', 0)
                memberArg:setLocalVar('ArcielaGuidingLightExpires', 0)
            end
        end)
    end
    mob:timer(100, function(mobArg)
        local party = nil
        local master = mobArg:getMaster()

        if master ~= nil then
            party = master:getPartyWithTrusts()
        end

        if party == nil then
            party = {}

            if master ~= nil then
                table.insert(party, master)
            end

            table.insert(party, mobArg)
        end

        for _, member in pairs(party) do
            if member ~= nil and member:isAlive() and member:checkDistance(mobArg) <= 10 then
                applyGuidingLightBuff(member)
            end
        end
    end)

    return 0
end

return mobskillObject
