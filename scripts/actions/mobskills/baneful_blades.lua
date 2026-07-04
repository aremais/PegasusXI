-----------------------------------
-- Baneful Blades
-- Rosulatia Trust special move.
-- Approximation: physical slashing damage with curse.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    params.numHits        = 2
    params.ftpMod         = { 1.5, 1.5, 1.5 }
    params.accMod         = 1
    params.dmgMod         = 1
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_2

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.CURSE_I, 25, 0, 180)
    end

    return info.damage
end

return mobskillObject
