-----------------------------------
-- Howling Gust
-- Darrcuiln Trust TP move.
-- Skillchain: Fragmentation / Compression.
-- Source notes this deals Wind damage.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------

local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    mob:messageBasic(xi.msg.basic.READIES_WS, 0, skill:getID())
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    params.baseDamage     = mob:getMainLvl() + 5
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
