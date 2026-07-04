-----------------------------------
-- King Cobra Clamp
-- Family: Humanoid (Trust: Nanaa Mihgo)
-- Description: Fan-shaped magical damage. Additional Effect: Stun.
-- Source notes: Trust sources list this as conal magic / fan-shaped, ignores shadows.
-- Additional Paralyze/Poison notes exist for Nanaa Mihgo in broader NPC sources, but Trust pages consistently confirm Stun.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.fTP            = { 3.0, 3.0, 3.0 } -- Approximation; exact fTP not captured.
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.NONE
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STUN, 1, 0, 4)
    end

    return info.damage
end

return mobskillObject
