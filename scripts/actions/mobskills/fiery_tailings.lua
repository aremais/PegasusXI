-----------------------------------
-- Fiery Tailings
-- Trust: Cid
-- Description: Cid-specific gun weaponskill. Deals AoE fire magical damage.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    mob:messageBasic(xi.msg.basic.READIES_WS, 0, skill:getID())
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    -- Source confirms Fiery Tailings is AoE; exact retail formula is not currently sourced.
    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.element        = xi.element.FIRE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
