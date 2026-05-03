-----------------------------------
-- Sweeping Gouge
-- Family: Raaz
-- Description: Delivers a twofold attack to enemies within a fan-shaped area.
--              Additional Effect: -25% Defense for 60 seconds. Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: Fan-shaped AoE
-- Skillchain: Induration
-- TODO: Verify fTP values from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 2
    params.fTP            = { 1.5, 2.0, 2.5 } -- TODO: Verify from retail captures
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- BGwiki: -25% Defense, duration explicitly 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 25, 0, 60)
    end

    return info.damage
end

return mobskillObject
