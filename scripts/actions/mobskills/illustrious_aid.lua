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
    local tp = skill:getTP()
    local healAmount = 500

    if tp >= 2000 then
        healAmount = 650
    end

    if tp >= 3000 then
        healAmount = 800
    end

    skill:setMsg(xi.mobskills.mobHealMove(target, healAmount))
    return healAmount
end

return mobskillObject
