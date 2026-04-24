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

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local accMod = 0

    if skill:getTP() >= 3000 then
        accMod = 100
    elseif skill:getTP() >= 2000 then
        accMod = 50
    end

    local params =
    {
        numHits = 2,
        ftpMod = { 3.5, 3.5, 3.5 },
        str_wsc = 0.30,
        dex_wsc = 0.30,
        accMod = accMod,
        atkVaries = { 1.25, 1.25, 1.25 },
        skill = xi.skill.NONE,
    }

    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, params)
    damage = xi.mobskills.mobFinalAdjustments(damage.dmg, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, 1)

    target:takeDamage(damage, mob, xi.attackType.PHYSICAL, xi.damageType.SLASHING)

    return damage
end

return mobskillObject