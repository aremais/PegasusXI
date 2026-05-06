-----------------------------------
-- Disembowel
-- Family: Lucani
-- Description: Deals physical damage to enemies within a fan-shaped area.
--              Additional Effect: VIT Down. Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE
-- Skillchain: Scission
-- TODO: Verify fTP, VIT Down value/duration, and skillchain from retail captures.
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

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Additional Effect: VIT Down for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.VIT_DOWN, 15, 0, 60)
    end

    return info.damage
end

return mobskillObject
