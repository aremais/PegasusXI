-----------------------------------
-- Dynastic Gravitas
-- AoE physical damage with Amnesia.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params =
    {
        numHits = 1,
        ftpMod  = { 1.0, 1.25, 1.5 },
        str_wSC = 0.25,
        mnd_wSC = 0.25,
        shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS,
    }

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        -- Wiki says it inflicts Amnesia. Keep duration modest for Trust balance.
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, 30)
    end

    return info.damage
end

return mobskillObject
