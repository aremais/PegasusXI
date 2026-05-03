-----------------------------------
-- Nihility Song
-- Family: Hippogryph
-- Description: Removes one beneficial magic effect (including food) from all enemies
--              within area of effect around pet. Area of effect varies with TP.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: AoE (range varies with TP — controlled via SQL/skill data)
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local dispel =  target:dispelStatusEffect(bit.bor(xi.effectFlag.DISPELABLE, xi.effectFlag.FOOD))

    if dispel == xi.effect.NONE then
        -- no effect
        skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT) -- no effect
    else
        skill:setMsg(xi.msg.basic.SKILL_ERASE)
    end

    return dispel
end

return mobskillObject
