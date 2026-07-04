-----------------------------------
-- Start From Scratch
-- Source notes: Teodor special move; conservative self recovery/aura approximation.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    -- Approximation: source says this erases debuffs, recovers Teodor,
    -- and grants his dark aura. Exact aura/forced Hemocladis behavior is held.
    mob:eraseStatusEffect()
    mob:addHP(mob:getMaxHP() * 0.50)

    skill:setMsg(xi.msg.basic.SELF_HEAL)
    return mob:getMaxHP() * 0.50
end

return mobskillObject
