-----------------------------------
-- Justicebreaker
-- Family: Humanoid (Trust: Naja Salaheem)
-- Description: Deals damage and increases magic damage taken.
-- Notes: The server has no obvious dedicated magic-damage-taken-down status from the source-lock scan,
-- so Magic Defense Down is used as the safest local approximation.
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
    params.fTP            = { 3.0, 3.0, 3.0 } -- Approximation; exact fTP not captured.
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Source: increases magic damage taken. Approximation: Magic Defense Down.
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAGIC_DEF_DOWN, 50, 0, 60)
    end

    return info.damage
end

return mobskillObject
