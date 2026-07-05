-----------------------------------
-- Gyre Strike
-- Excenmille (S) Trust TP move.
-- Source notes: single-target magical damage; BGWiki notes Paralyze.
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
    params.baseDamage     = mob:getMainLvl() + 10
    params.fTP            = { 2.5, 2.5, 2.5 }
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.NONE
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 20, 0, 60)
    end

    return info.damage
end

return mobskillObject
