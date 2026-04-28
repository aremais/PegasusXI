-----------------------------------
-- Chimera Ripper
-- Delivers a single-hit attack.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill, action)
    local ftp = 6.0

    if skill:getTP() >= 3000 then
        ftp = 11.0
    elseif skill:getTP() >= 2000 then
        ftp = 8.5
    end

    local params =
    {
        numHits = 1,
        fTP = { ftp, ftp, ftp },
        str_wSC = 0.50,
        skill = xi.skill.NONE,
    }

    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)
    damage.damage = xi.mobskills.mobFinalAdjustments(damage.damage, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, damage.hitsLanded)

    target:takeDamage(damage.damage, mob, xi.attackType.PHYSICAL, xi.damageType.SLASHING)

    return damage.damage
end

return mobskillObject
