-----------------------------------
-- Hastega II
-- Family: Garuda (Player Pet)
-- Notes: Lv99 Blood Pact: Ward. Gives party members within area of effect
--        the effect of "Haste."
--        Per BG-Wiki: Magic Haste bonus of 30% (307/1024). Base duration 3 minutes.
-- Reference: https://www.bg-wiki.com/ffxi/Hastega_II
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local bonusTime = utils.clamp(summoner:getSkillLevel(xi.skill.SUMMONING_MAGIC) - 300, 0, 200)
    local duration  = 180 + bonusTime

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    -- ~30% haste using a slightly higher rate than Haste II spell to match avatar buff behavior.
    -- 307/1024 ~= 29.98%
    local typeEffect = xi.effect.HASTE
    if target:addStatusEffect(typeEffect, { power = 3070, duration = duration, origin = pet }) then
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
