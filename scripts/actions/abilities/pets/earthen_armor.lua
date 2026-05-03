-----------------------------------
-- Earthen Armor
-- Family: Titan (Player Pet)
-- Notes: Lv82 Blood Pact: Ward. Mitigates the impact of severely damaging
--        attacks for party members within area of effect.
--        Per BG-Wiki: Reduces any single action that would have taken over
--        75% of max HP by 45%. Stacks with Sentinel's Scherzo (cap -95% total).
--        Base duration 1 minute.
--
--        Engine wiring: HandleSevereDamageEffect in src/map/utils/battleutils.cpp
--        already implements the (Power = threshold %, SubPower = reduction %)
--        contract for EFFECT_MIGAWARI. The TODO note in HandleSevereDamage
--        indicates EARTHEN_ARMOR still needs to be wired up there with:
--            damage = HandleSevereDamageEffect(PDefender, EFFECT_EARTHEN_ARMOR, damage, false);
--        Until that hook is added, this lua applies the status effect, but
--        the damage cap will not actually fire in core.
-- Reference: https://www.bg-wiki.com/ffxi/Earthen_Armor
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

    -- Power = HP% threshold above which a single hit triggers the cap (75 = 75%).
    -- SubPower = damage reduction percentage applied when threshold is crossed (45 = -45%).
    local typeEffect = xi.effect.EARTHEN_ARMOR
    target:delStatusEffect(typeEffect)

    if target:addStatusEffect(typeEffect, { power = 75, subPower = 45, duration = duration, origin = pet }) then
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
