-----------------------------------
-- Jettatura
-- Family: Hippogryph
-- Description: Terrorizes enemies within a fan-shaped area.
--              Duration of effect varies with TP, from 15 to 25 seconds.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE
-- Skillchain: N/A
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
        duration = 25 -- 25 seconds
    elseif tp >= 1000 then
        duration = 20 -- 20 seconds
    else
        duration = 15 -- 15 seconds
    end

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, duration))

    return xi.effect.TERROR
end

return mobskillObject
