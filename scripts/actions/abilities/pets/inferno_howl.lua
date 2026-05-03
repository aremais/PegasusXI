-----------------------------------
-- Inferno Howl
-- Family: Ifrit (Player Pet)
-- Notes: Lv88 Blood Pact: Ward. Grants the effect of "Enfire" to party
--        members within area of effect.
--        Per BG-Wiki damage formula: 20 + TRUNC((Skill - 300) / 10).
--        Base duration 1 minute.
-- Reference: https://www.bg-wiki.com/ffxi/Inferno_Howl
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local bonusTime = utils.clamp(summoner:getSkillLevel(xi.skill.SUMMONING_MAGIC) - 300, 0, 200)
    local duration  = 60 + bonusTime

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    -- Per BG-Wiki: damage = 20 + TRUNC((SummoningSkill - 300) / 10).
    -- Floors at 20 if skill <= 300.
    local skill = summoner:getSkillLevel(xi.skill.SUMMONING_MAGIC)
    local power = 20 + math.max(0, math.floor((skill - 300) / 10))

    local typeEffect = xi.effect.ENFIRE
    target:delStatusEffect(typeEffect)

    if target:addStatusEffect(typeEffect, { power = power, duration = duration, origin = pet }) then
        if target:getID() == action:getPrimaryTargetID() then
            petskill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT_2)
        else
            petskill:setMsg(xi.msg.basic.JA_GAIN_EFFECT)
        end
    else
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return
    end

    return typeEffect
end

return abilityObject
