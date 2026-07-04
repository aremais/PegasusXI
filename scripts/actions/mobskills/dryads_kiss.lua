-----------------------------------
-- Dryad's Kiss
-- Rosulatia Trust special move.
-- Approximation: HP drain-style magical damage.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    params.baseDamage     = mob:getMainLvl() + 2
    params.numHits        = 1
    params.ftpMod         = { 1.75, 1.75, 1.75 }
    params.damageType     = xi.damageType.DARK
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        skill:setMsg(xi.mobskills.mobDrainMove(mob, target, xi.mobskills.drainType.HP, info.damage, info.attackType, info.damageType))
    end

    return info.damage
end

return mobskillObject
