-----------------------------------
-- Vehement Resolution
-- Family: Humanoid (Trust: Morimar)
-- Description: Morimar special recovery move.
-- Source behavior: Used below 50% HP; restores HP, removes debuffs, and empowers his next WS.
-- Notes: Exact aura/glow packet and forced-next-WS behavior are held; localVar marker is set for Trust Lua/scripts to consume later.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- Source notes indicate this is used when Morimar is below 50% HP.
    if mob:getHPP() > 50 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local missingHP = mob:getMaxHP() - mob:getHP()

    if missingHP > 0 then
        mob:addHP(missingHP)
    end

    -- Full erase-style behavior. This mirrors common LSB mobskill usage.
    mob:eraseAllStatusEffect()

    -- Mark that the next Morimar WS should be treated as empowered / 12 Blades-preferred.
    -- The exact forced next-WS behavior is held until we confirm a safe Trust TP hook.
    mob:setLocalVar('MorimarVehementResolution', 1)

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return missingHP
end

return mobskillObject
