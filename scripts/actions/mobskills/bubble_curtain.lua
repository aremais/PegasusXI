-----------------------------------
-- Bubble Curtain
-- Family: Barnacled Crab
-- Description: Reduces magical damage received by 50% for pet and Beastmaster.
--              Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- Notes: Nightmare Crabs use an enhanced version that applies a Magic Defense Boost
--        that cannot be dispelled.
-- TODO: Apply -50% MDT buff to BST master when mob:getMaster() ~= nil.
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

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.SHELL, 5000, 0, duration))

    -- Also apply -50% MDT to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.SHELL, { power = 5000, duration = duration, origin = master })
    end

    return xi.effect.SHELL
end

return mobskillObject
