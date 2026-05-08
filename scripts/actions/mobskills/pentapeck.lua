-----------------------------------
-- Pentapeck
-- Family: Tulfaire
-- Description: Deals physical damage to a target. Additional Effect: Amnesia.
--              Duration of effect varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 5 shadows
-- Range: Single target
-- Skillchain: Light / Distortion
-- TODO: Verify fTP and Amnesia duration from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    local wdmg = mob:getWeaponDmg()
    params.baseDamage     = (wdmg > 0) and wdmg or mob:getMainLvl()
    params.numHits        = 5
    params.fTP            = { 1.0, 1.25, 1.5 } -- TODO: Verify from retail captures
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local tp = skill:getTP()
    local duration

    if tp >= 2000 then
        duration = 90  -- 1.5 minutes
    elseif tp >= 1000 then
        duration = 60  -- 1 minute
    else
        duration = 30  -- 30 seconds
    end

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, duration)
    end

    return info.damage
end

return mobskillObject
