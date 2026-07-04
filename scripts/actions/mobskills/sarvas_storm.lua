-----------------------------------
-- Sarva's Storm
-- Jakoh Wahcondalo UC Trust TP move.
-- Functionally mirrors Rudra's Storm.
-- Description: Delivers a single hit attack. Damage varies with TP. Additional Effect: Weight
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    print(string.format("[JakohUC][SarvasStorm] ENTER mob=%s target=%s tp=%s", mob:getName(), target:getName(), mob:getTP()))

    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 3.25, 4.25, 5.25 }
    -- params.dex_wSC        = 0.6 -- TODO: Capture if mobskill weaponskills have wSC.
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.WEIGHT, 25, 0, 60)
    end

    print(string.format("[JakohUC][SarvasStorm] EXIT damage=%s attackType=%s damageType=%s", tostring(info.damage), tostring(info.attackType), tostring(info.damageType)))

    return info.damage
end

return mobskillObject
