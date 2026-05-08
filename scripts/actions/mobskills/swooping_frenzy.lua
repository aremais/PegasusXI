-----------------------------------
-- Swooping Frenzy
-- Family: Tulfaire
-- Description: Deals physical damage to enemies in a fan-shaped area.
--              Additional Effects: Defense Down 25% & MDB Down 25.
--              Duration of effect varies with TP, from 60 seconds to 2.5 minutes.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE
-- Skillchain: Fusion / Reverberation
-- TODO: Verify fTP from retail captures.
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
    params.numHits        = 1
    params.fTP            = { 2.0, 2.5, 3.0 } -- TODO: Verify from retail captures
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local tp = skill:getTP()
    local duration

    if tp >= 2000 then
        duration = 150 -- 2.5 minutes
    elseif tp >= 1000 then
        duration = 105 -- 1.75 minutes (midpoint)
    else
        duration = 60  -- 1 minute
    end

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 25, 0, duration)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAGIC_DEF_DOWN, 25, 0, duration)
    end

    return info.damage
end

return mobskillObject
