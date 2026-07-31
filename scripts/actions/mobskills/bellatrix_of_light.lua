-----------------------------------
-- Bellatrix of Light
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    -- Stance/transition action. No direct combat effect here.
    return 0
end

return mobskillObject
