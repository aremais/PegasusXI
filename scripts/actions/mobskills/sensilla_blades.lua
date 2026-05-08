-----------------------------------
-- Sensilla Blades
-- Family: Chapuli
-- Description: Deals physical damage to enemies within a fan-shaped area. Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE (7 yalms)
-- Skillchain: Scission
-- Notes: Used by Scissorleg Xerin and Bouncing Bertha jug pets.
-- TODO: Verify fTP values from retail captures.
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
    end

    return info.damage
end

return mobskillObject
