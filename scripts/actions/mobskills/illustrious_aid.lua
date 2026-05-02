-----------------------------------
-- Illustrious Aid
-- AoE HP restore. Used when party members are in yellow HP.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local healAmount = 650

    skill:setMsg(xi.mobskills.mobHealMove(target, healAmount))
    return healAmount
end

return mobskillObject
