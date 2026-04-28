-----------------------------------
-- String Clipper
-- Delivers a twofold attack. Accuracy varies with TP.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill, action)
    local accMod = 0

    if skill:getTP() >= 3000 then
        accMod = 100
    elseif skill:getTP() >= 2000 then
        accMod = 50
    end

    local params =
    {
        numHits = 2,
        fTP = { 3.5, 3.5, 3.5 },
        str_wSC = 0.30,
        dex_wSC = 0.30,
        accuracyModifier = { accMod, accMod, accMod },
        attackMultiplier = { 1.25, 1.25, 1.25 },
        skill = xi.skill.NONE,
    }

    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)
    damage.damage = xi.mobskills.mobFinalAdjustments(damage.damage, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, damage.hitsLanded)

    target:takeDamage(damage.damage, mob, xi.attackType.PHYSICAL, xi.damageType.SLASHING)

    return damage.damage
end

return mobskillObject
