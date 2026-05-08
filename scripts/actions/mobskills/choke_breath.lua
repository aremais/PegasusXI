-----------------------------------
-- Choke Breath
-- Family: Hippogryph
-- Description: Deals Earth elemental damage to enemies within a fan-shaped area.
--              Additional Effects: Paralysis & Silence. Duration of effect varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE
-- Skillchain: N/A
-- TODO: Verify fTP and effect power/duration from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 1.5, 2.0, 2.5 } -- TODO: Verify from retail captures
    params.element        = xi.element.EARTH
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.EARTH
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local tp = skill:getTP()
    local duration

    if tp >= 2000 then
        duration = 60  -- 1 minute
    elseif tp >= 1000 then
        duration = 45  -- 45 seconds
    else
        duration = 30  -- 30 seconds
    end

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 25, 0, duration)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SILENCE, 1, 0, duration)
    end

    return info.damage
end

return mobskillObject
