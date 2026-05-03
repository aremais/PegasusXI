-----------------------------------
-- Fantod
-- Family: Hippogryph
-- Description: Grants an Attack boost applied to the next attack. Damage varies with TP.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- TODO: Verify boost power at each TP tier from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local tp = skill:getTP()
    local power

    if tp >= 2000 then
        power = 500 -- TODO: Verify from retail captures
    elseif tp >= 1000 then
        power = 400
    else
        power = 300
    end

    local subPower = 1 -- Special formula for boost increasing base damage

    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.BOOST, power, 0, 180, nil, subPower))

    return xi.effect.BOOST
end

return mobskillObject
