-----------------------------------
-- Rise from Ashes
-- Iroha II Trust TP move.
-- Source behavior: restores HP/MP, grants Stoneskin, and helps sleeping party members.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local hpAmount = math.floor(target:getMaxHP() * 0.25)
    local mpAmount = math.floor(target:getMaxMP() * 0.25)

    target:addHP(hpAmount)

    if target:getMaxMP() > 0 then
        target:addMP(mpAmount)
    end

    target:addStatusEffect(xi.effect.STONESKIN, 500, 0, 180)

    if target:hasStatusEffect(xi.effect.SLEEP_I) then
        target:delStatusEffect(xi.effect.SLEEP_I)
    elseif target:hasStatusEffect(xi.effect.SLEEP_II) then
        target:delStatusEffect(xi.effect.SLEEP_II)
    end

    return hpAmount
end

return mobskillObject