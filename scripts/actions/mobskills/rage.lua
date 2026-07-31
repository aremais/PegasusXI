-----------------------------------
-- Rage
-- Family: Ram, Marid
-- Description: Grants Berserk effect (+ATK, -DEF) to pet and Beastmaster.
--              Duration of effect varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- TODO: Verify exact Berserk power and duration from retail captures.
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

    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.BERSERK, 45, 0, duration))

    -- Also apply Berserk to BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addStatusEffect(xi.effect.BERSERK, { power = 45, duration = duration, origin = master })
    end

    return xi.effect.BERSERK
end

return mobskillObject
