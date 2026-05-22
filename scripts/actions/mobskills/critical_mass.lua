-----------------------------------
-- Critical Mass
-- Family: Cid Trust
-- Description: Deals single-target Fire damage.
-- Skillchain: Fusion / Impaction
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + mob:getWeaponDmg()
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.element        = xi.element.FIRE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
