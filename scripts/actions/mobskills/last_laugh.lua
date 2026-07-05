-----------------------------------
-- Last Laugh
-- Trust: Balamor
-- Description: Deals dark magical damage. Additional effect: HP drain.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}
    local targetHP = target:getHP()

    params.baseDamage       = mob:getMainLvl() + 2
    params.fTP              = { 2.75, 2.75, 2.75 }
    params.element          = xi.element.DARK
    params.attackType       = xi.attackType.MAGICAL
    params.damageType       = xi.damageType.DARK
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    params.dStatMultiplier  = 2
    params.dStatAttackerMod = xi.mod.INT
    params.dStatDefenderMod = xi.mod.INT

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        -- Retail/wiki notes Last Laugh as Balamor's self-heal.
        -- Standard drain behavior does not heal from undead targets.
        if not target:isUndead() then
            mob:addHP(utils.clamp(info.damage, 0, targetHP))
        end
    end

    return info.damage
end

return mobskillObject
