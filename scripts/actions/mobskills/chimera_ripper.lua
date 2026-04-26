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

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local ftp = 6.0

    if skill:getTP() >= 3000 then
        ftp = 11.0
    elseif skill:getTP() >= 2000 then
        ftp = 8.5
    end

    local params =
    {
        numHits = 1,
        ftpMod = { ftp, ftp, ftp },
        str_wsc = 0.50,
        skill = xi.skill.NONE,
    }

    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, params)
    damage = xi.mobskills.mobFinalAdjustments(damage.dmg, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, 1)

    target:takeDamage(damage, mob, xi.attackType.PHYSICAL, xi.damageType.SLASHING)

    return damage
end

return mobskillObject
