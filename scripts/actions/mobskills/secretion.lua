-----------------------------------
-- Secretion
-- Family: Lizard
-- Description: +25 Evasion for pet and Beastmaster. Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: AoE (radial, centered on pet)
-- Notes: Retail behavior applies buff to BST master as well.
--        BST master buff requires additional BST-specific logic (TODO).
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

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.EVASION_BOOST, 25, 0, duration))

    -- Also apply +25 Evasion to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.EVASION_BOOST, { power = 25, duration = duration, origin = master })
    end

    return xi.effect.EVASION_BOOST
end

return mobskillObject
