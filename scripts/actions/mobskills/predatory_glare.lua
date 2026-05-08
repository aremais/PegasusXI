-----------------------------------
-- Predatory Glare
-- Family: Tiger (Tulfaire - SoA)
-- Description: Gazes at enemies in a frontal cone, inflicting Terror.
-- Type: Status
-- Utsusemi/Blink absorb: Unblockable
-- Range: Frontal cone (gaze)
-- TODO: Verify Terror duration and cone radius from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local duration = 10 -- TODO: Verify from retail captures

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, duration))

    return xi.effect.TERROR
end

return mobskillObject
