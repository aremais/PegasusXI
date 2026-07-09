-----------------------------------
-- Salvation Scythe
-- Family: Humanoid Scythe Weaponskill
-- Description: Deals AoE darkness damage. Additional effect: Poison, Paralysis, Slow, and Bio.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage       = mob:getMainLvl() + 2
    params.fTP              = { 2.0, 2.0, 2.0 }
    params.element          = xi.element.DARK
    params.attackType       = xi.attackType.MAGICAL
    params.damageType       = xi.damageType.DARK
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    params.dStatMultiplier  = 1
    params.dStatAttackerMod = xi.mod.INT
    params.dStatDefenderMod = xi.mod.INT

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Domina Shantotto's Salvation Scythe additional effects.
        -- Values are intentionally conservative until retail captures are available.
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.POISON,    10,   3, 60)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 15,   0, 60)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW,      1500, 0, 60)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIO,       10,   3, 60)
    end

    return info.damage
end

return mobskillObject
