-----------------------------------
-- Bellatrix of Shadows
-- Physical damage.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params =
    {
        numHits = 1,
        ftpMod  = { 1.5, 2.0, 2.5 },
        str_wSC = 0.3,
        dex_wSC = 0.3,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
    }

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)
    xi.mobskills.processDamage(mob, target, skill, action, info)

    return info.damage
end

return mobskillObject
