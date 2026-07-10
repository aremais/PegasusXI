-----------------------------------
-- Tongue Lash
-- Trust: Rongelouts
-- Source notes: Rongelouts unique TP move. Exact formula/effects are not
-- fully captured, so this uses a conservative physical damage implementation.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.numHits    = 1
    params.ftpMod     = { 2.0, 2.0, 2.0 } -- Approximation; exact fTP not captured.
    params.str_wsc    = 0.30
    params.vit_wsc    = 0.30
    params.skill      = xi.skill.SWORD
    params.includemab = false
    params.attackType = xi.attackType.PHYSICAL
    params.damageType = xi.damageType.BLUNT

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
