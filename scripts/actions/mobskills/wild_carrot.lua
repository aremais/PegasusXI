-----------------------------------
-- Wild Carrot
-- Family: Rabbit
-- Description: Restores HP of all party members within area of effect.
--              HP restored varies with TP.
-- Type: Healing
-- Utsusemi/Blink absorb: N/A
-- Range: AoE (self-centered)
-- TODO: Apply HP restore to BST master when mob:getMaster() ~= nil.
-- TODO: Verify heal amounts at each TP tier from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local tp = skill:getTP()
    local healAmount

    if tp >= 2000 then
        healAmount = math.floor(mob:getMaxHP() * 0.35) -- ~35% max HP
    elseif tp >= 1000 then
        healAmount = math.floor(mob:getMaxHP() * 0.25) -- ~25% max HP
    else
        healAmount = math.floor(mob:getMaxHP() * 0.15) -- ~15% max HP
    end

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    -- Also heal BST master if this is a jug pet
    local master = mob:getMaster()
    if master ~= nil then
        master:addHP(healAmount)
    end

    return xi.mobskills.mobHealMove(target, healAmount)
end

return mobskillObject
