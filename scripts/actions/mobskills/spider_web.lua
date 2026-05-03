-----------------------------------
-- Spider Web
-- Family: Spider
-- Description: Applies 3% Slow to enemies within range.
--              Duration of effect varies with TP.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: AoE
-- Skillchain: N/A
-- TODO: Verify exact Slow duration at each TP tier from retail captures.
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
        duration = 90  -- 1.5 minutes
    elseif tp >= 1000 then
        duration = 75  -- 1.25 minutes
    else
        duration = 60  -- 1 minute
    end

    -- 3% Slow; scale: power 50 = 1%, so 3% = 150
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 150, 0, duration))

    return xi.effect.SLOW
end

return mobskillObject
