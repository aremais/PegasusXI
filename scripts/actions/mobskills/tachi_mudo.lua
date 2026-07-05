-----------------------------------
-- Tachi: Mudo
-- Functionally identical to Tachi: Fudo, without Aftermath.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.numHits         = 1
    params.ftpMod          = { 3.75, 3.75, 3.75 }
    -- params.str_wSC       = 0.6 -- TODO: Capture if mobskill weaponskills have wSC.
    params.critVaries      = { 0.15, 0.15, 0.15 }
    params.attackType      = xi.attackType.PHYSICAL
    params.damageType      = xi.damageType.SLASHING
    params.shadowBehavior  = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
