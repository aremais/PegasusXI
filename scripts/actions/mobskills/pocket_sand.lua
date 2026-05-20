-----------------------------------
-- Pocket Sand
-- Deals dark damage in a fan-shaped area. Additional effect: Blindness.
-----------------------------------
require("scripts/globals/mobskills")
require("scripts/globals/status")
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local params =
    {
        numHits = 1,
        ftpMod = { 2.0, 2.0, 2.0 },
        str_wsc = 0.0,
        dex_wsc = 0.0,
        vit_wsc = 0.0,
        agi_wsc = 0.0,
        int_wsc = 0.0,
        mnd_wsc = 0.0,
        chr_wsc = 0.0,
        skill = xi.skill.CLUB,
        element = xi.element.DARK,
        damageType = xi.damageType.DARK,
    }

    local action = xi.mobskills.useMobSkill(mob, target, skill, params)
    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)
    local damage = xi.mobskills.mobFinalAdjustments(info.dmg, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 20, 0, 60)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)
    skill:setMsg(xi.msg.basic.DAMAGE)

    return damage
end

return mobskillObject
