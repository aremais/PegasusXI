-----------------------------------
-- Scissor Guard
-- Family: Barnacled Crab
-- Description: Enhances Defense by 100% for pet and Beastmaster.
--              Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- TODO: Apply +100% DEF buff to BST master when mob:getMaster() ~= nil.
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
        duration = 120 -- 2 minutes
    elseif tp >= 1000 then
        duration = 90  -- 1.5 minutes
    else
        duration = 60  -- 1 minute
    end

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 100, 0, duration))

    -- Also apply +100% Defense to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.DEFENSE_BOOST, { power = 100, duration = duration, origin = master })
    end

    return xi.effect.DEFENSE_BOOST
end

return mobskillObject
