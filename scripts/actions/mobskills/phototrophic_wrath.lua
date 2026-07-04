-----------------------------------
-- Phototrophic Wrath
-- Ygnas Trust approximation.
-- Source behavior: AoE Haste, Attack Boost, Enlight, Magic Attack Boost.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local function addMobskillStatus(mob, target, effect, power, tick, duration)
    if effect ~= nil then
        xi.mobskills.mobStatusEffectMove(mob, target, effect, power, tick, duration)
    end
end

local function applyWrath(mob, target)
    addMobskillStatus(mob, target, xi.effect.HASTE, 1500, 0, 60)
    addMobskillStatus(mob, target, xi.effect.ATTACK_BOOST, 25, 0, 60)
    addMobskillStatus(mob, target, xi.effect.ENLIGHT, 25, 0, 60)
    addMobskillStatus(mob, target, xi.effect.MAGIC_ATK_BOOST, 25, 0, 60)
end

local function applyToTrustParty(mob, primaryTarget)
    local applied = false
    local master = mob:getMaster()

    if master ~= nil then
        local party = master:getPartyWithTrusts()

        if party ~= nil then
            for _, member in pairs(party) do
                if member ~= nil and member:isAlive() and member:checkDistance(mob) <= 20 then
                    applyWrath(mob, member)
                    applied = true
                end
            end
        end
    end

    if not applied and primaryTarget ~= nil then
        applyWrath(mob, primaryTarget)
    end
end

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    applyToTrustParty(mob, target)

    skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT)

    return xi.effect.HASTE
end

return mobskillObject
