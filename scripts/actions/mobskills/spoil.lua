-----------------------------------
-- Spoil
-- Family: Beetle
-- Description: -20% Strength to an enemy which decays over time.
--              Duration of effect varies with TP, from 3 minutes to 9 minutes.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Single target
-- TODO: Verify exact TP breakpoints for duration scaling.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local tp = skill:getTP()
    local duration

    if tp >= 2000 then
        duration = 540 -- 9 minutes
    elseif tp >= 1000 then
        duration = 360 -- 6 minutes
    else
        duration = 180 -- 3 minutes
    end

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STR_DOWN, 20, 3, duration))

    return xi.effect.STR_DOWN
end

return mobskillObject
