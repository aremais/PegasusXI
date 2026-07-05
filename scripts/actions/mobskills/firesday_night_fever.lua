-----------------------------------
-- Firesday Night Fever
-- Mumor II Trust approximation.
-- Source behavior: below-HP recovery/aura trigger.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local duration = 240

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if mob:hasStatusEffect(xi.effect.MUMORS_RADIANCE) then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local hp = mob:getMaxHP() - mob:getHP()
    local mp = mob:getMaxMP() - mob:getMP()

    if hp > 0 then
        mob:addHP(hp)
    end

    if mp > 0 then
        mob:addMP(mp)
    end

    mob:addStatusEffect(xi.effect.MUMORS_RADIANCE, 1, 0, duration)
    mob:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, 25, 0, duration)
    mob:addStatusEffect(xi.effect.REGAIN, 50, 3, duration)
    mob:setLocalVar('MUMOR_II_FEVER_STEP', 0)

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return hp
end

return mobskillObject
