-----------------------------------
-- Frenzied Rage
-- Family: Coeurl, Lynx
-- Description: Increases attack of pet and master if in area of effect.
--              Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: AoE (radial, centered on pet)
-- Notes: 20% Attack Boost. Retail applies buff to BST master as well.
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

    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.ATTACK_BOOST, 20, 0, duration))

    -- Also apply +20% Attack to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 20, duration = duration, origin = master })
    end

    return xi.effect.ATTACK_BOOST
end

return mobskillObject
