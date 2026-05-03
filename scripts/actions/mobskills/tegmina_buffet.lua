-----------------------------------
-- Tegmina Buffet
-- Family: Chapuli
-- Description: Deals physical damage to enemies within range.
--              Additional Effect: Choke (-33 VIT & 15 damage/tic) for 60 sec.
--              Damage varies with TP.
-- Type: Physical
-- Utsusemi/Blink absorb: 3 shadows
-- Range: AoE (6 yalms)
-- Skillchain: Distortion / Detonation
-- Notes: Used by Scissorleg Xerin and Bouncing Bertha jug pets.
--        Known for very high AoE damage output with pet ATK/ACC gear and support buffs.
--        Can reach 30,000+ damage at level 119 with GEO/COR support.
-- TODO: Verify fTP values from retail captures.
-- TODO: Verify Choke tick rate (currently 3 sec) and VIT down value (currently 33).
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 4.0, 5.0, 6.0 } -- TODO: Verify from retail captures; high fTP to reflect known damage output
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Choke: 15 damage per tick, every 3 seconds, 60 second duration
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.CHOKE, 15, 3, 60)

        -- VIT Down: -33 VIT for 60 seconds
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.VIT_DOWN, 33, 0, 60)
    end

    return info.damage
end

return mobskillObject
