-----------------------------------
-- Lovely Miracle Waltz
-- Mumor II Trust approximation.
-- Branch-safe support move.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- Mumor II retail chain uses Neo -> Super -> Eternal -> Final after Firesday.
    -- This move is intentionally not part of the active Mumor II chain.
    return 1
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local heal = math.floor(mob:getMaxHP() * 0.25)
    local missingHP = mob:getMaxHP() - mob:getHP()

    if heal > missingHP then
        heal = missingHP
    end

    if heal > 0 then
        mob:addHP(heal)
    end

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return heal
end

return mobskillObject