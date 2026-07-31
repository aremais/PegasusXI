-----------------------------------
-- Zealous Snort
-- Family: Raaz
-- Description: +25% Haste, +25 MDB, and increases the likelihood of both countering
--              and guarding for pet and Beastmaster. Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: AoE (radial, centered on pet)
-- Effect IDs verified: HASTE=33, MAGIC_DEF_BOOST=191, COUNTER_BOOST=486, GUARDING_RATE_BOOST=622
-- TODO: Verify exact TP breakpoints for duration scaling.
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
        duration = 120
    elseif tp >= 1000 then
        duration = 90
    else
        duration = 60
    end

    -- +25% Haste
    xi.mobskills.mobBuffMove(mob, xi.effect.HASTE, 25, 0, duration)

    -- +25 Magic Defense Bonus (xi.effect.MAGIC_DEF_BOOST = 191)
    xi.mobskills.mobBuffMove(mob, xi.effect.MAGIC_DEF_BOOST, 25, 0, duration)

    -- Counter rate boost (xi.effect.COUNTER_BOOST = 486)
    xi.mobskills.mobBuffMove(mob, xi.effect.COUNTER_BOOST, 1, 0, duration)

    -- Guard rate boost (xi.effect.GUARDING_RATE_BOOST = 622)
    xi.mobskills.mobBuffMove(mob, xi.effect.GUARDING_RATE_BOOST, 1, 0, duration)

    -- Also apply all buffs to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.HASTE,               { power = 25, duration = duration, origin = master })
        master:addStatusEffect(xi.effect.MAGIC_DEF_BOOST,     { power = 25, duration = duration, origin = master })
        master:addStatusEffect(xi.effect.COUNTER_BOOST,       { power = 1,  duration = duration, origin = master })
        master:addStatusEffect(xi.effect.GUARDING_RATE_BOOST, { power = 1,  duration = duration, origin = master })
    end

    skill:setMsg(238) -- "XXX gains the effect of XXX"

    return xi.effect.HASTE
end

return mobskillObject
