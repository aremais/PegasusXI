-----------------------------------
-- Metallic Body
-- Family: Barnacled Crab
-- Description: Gives the effect of ~200 HP "Stoneskin" for pet and Beastmaster.
--              Duration of effect varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- TODO: Apply Stoneskin to BST master when mob:getMaster() ~= nil.
-- TODO: Verify exact Stoneskin HP value from retail captures (~200 per BGwiki).
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
        duration = 300 -- 5 minutes
    elseif tp >= 1000 then
        duration = 180 -- 3 minutes
    else
        duration = 120 -- 2 minutes
    end

    local power = 200 -- ~200 HP Stoneskin per BGwiki

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.STONESKIN, power, 0, duration))

    -- Also apply ~200 HP Stoneskin to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.STONESKIN, { power = power, duration = duration, origin = master })
    end

    return xi.effect.STONESKIN
end

return mobskillObject
