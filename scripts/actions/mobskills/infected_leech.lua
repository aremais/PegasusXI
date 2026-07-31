-----------------------------------
-- Infected Leech
-- Family: Mosquito
-- Description: Deals Darkness elemental damage and absorbs HP from enemies in a
--              fan-shaped area. Additional Effect: Plague (-50 TP/tic) for 45 seconds.
--              Additional effect duration varies with TP.
-- Type: Magical
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Fan-shaped AoE
-- Skillchain: N/A
-- TODO: Verify fTP and HP drain amount from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 1.5, 1.5, 1.5 } -- TODO: Verify from retail captures
    params.element        = xi.element.DARK
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.DARK
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local tp = skill:getTP()
    local duration

    if tp >= 2000 then
        duration = 45 -- 45 seconds (BGwiki explicit)
    elseif tp >= 1000 then
        duration = 30 -- 30 seconds
    else
        duration = 15 -- 15 seconds
    end

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- HP drain: restore a portion of damage dealt to caster
        local drainAmount = math.floor(info.damage * 0.5) -- TODO: Verify drain ratio
        mob:addHP(drainAmount)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 50, 3, duration) -- -50 TP/tic
    end

    return info.damage
end

return mobskillObject
