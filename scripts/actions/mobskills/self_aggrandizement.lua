-----------------------------------
-- Self-Aggrandizement
-- Ingrid II Trust TP move.
-- Recovers HP and removes sleep from party targets.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local amount = math.floor(target:getMaxHP() * 0.25)

    target:addHP(amount)

    if target:hasStatusEffect(xi.effect.SLEEP_I) then
        target:delStatusEffect(xi.effect.SLEEP_I)
    elseif target:hasStatusEffect(xi.effect.SLEEP_II) then
        target:delStatusEffect(xi.effect.SLEEP_II)
    end

    return amount
end

return mobskillObject