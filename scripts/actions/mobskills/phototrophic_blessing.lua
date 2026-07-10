-----------------------------------
-- Phototrophic Blessing
-- Ygnas Trust approximation.
-- Source behavior: AoE heal plus Regen, Defense Boost, Magic Defense Boost.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local function addMobskillStatus(mob, target, effect, power, tick, duration)
    if effect ~= nil then
        xi.mobskills.mobStatusEffectMove(mob, target, effect, power, tick, duration)
    end
end

local function applyBlessing(mob, target)
    local power = 500 + mob:getMainLvl() * 8

    target:addHP(power)
    target:wakeUp()

    addMobskillStatus(mob, target, xi.effect.REGEN, 30, 3, 60)
    addMobskillStatus(mob, target, xi.effect.DEFENSE_BOOST, 25, 0, 60)
    addMobskillStatus(mob, target, xi.effect.MAGIC_DEF_BOOST, 25, 0, 60)

    return power
end

local function applyToTrustParty(mob, primaryTarget)
    local total = 0
    local applied = false
    local master = mob:getMaster()

    if master ~= nil then
        local party = master:getPartyWithTrusts()

        if party ~= nil then
            for _, member in pairs(party) do
                if member ~= nil and member:isAlive() and member:checkDistance(mob) <= 20 then
                    total = total + applyBlessing(mob, member)
                    applied = true
                end
            end
        end
    end

    if not applied and primaryTarget ~= nil then
        total = applyBlessing(mob, primaryTarget)
    end

    return total
end

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local total = applyToTrustParty(mob, target)

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return total
end

return mobskillObject
