-----------------------------------
-- Diamond Storm
-- Family: Shiva (Player Pet)
-- Notes: Lv90 Blood Pact: Ward. Reduces evasion for enemies within area of effect.
--        Per BG-Wiki: applies Evasion -25, base duration 3 minutes, 10' radius.
-- Reference: https://www.bg-wiki.com/ffxi/Diamond_Storm
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    -- Check nullification.
    if
        xi.data.statusEffect.isTargetImmune(target, xi.effect.EVASION_DOWN, xi.element.ICE) or
        xi.data.statusEffect.isTargetResistant(pet, target, xi.effect.EVASION_DOWN) or
        xi.data.statusEffect.isEffectNullified(target, xi.effect.EVASION_DOWN, 0) or
        target:hasStatusEffect(xi.effect.EVASION_DOWN)
    then
        if target:getID() == action:getPrimaryTargetID() then
            petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        else
            petskill:setMsg(xi.msg.basic.NO_EFFECT)
        end

        return xi.effect.EVASION_DOWN
    end

    -- Magic accuracy resist roll.
    local bonus  = xi.summon.getSummoningSkillOverCap(pet)
    local resist = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.ICE, xi.mod.INT, xi.effect.EVASION_DOWN, bonus)
    if resist < 0.5 then
        petskill:setMsg(xi.msg.basic.JA_MISS_2) -- resist message
        return xi.effect.EVASION_DOWN
    end

    -- Per BG-Wiki: -25 Evasion, base 3 minute duration scaled by resist.
    local duration = math.floor(180 * resist)

    target:addStatusEffect(xi.effect.EVASION_DOWN, { power = 25, duration = duration, origin = pet })
    if target:getID() == action:getPrimaryTargetID() then
        petskill:setMsg(xi.msg.basic.JA_RECEIVES_EFFECT_2)
    else
        petskill:setMsg(xi.msg.basic.JA_RECEIVES_EFFECT)
    end

    target:updateEnmity(pet)

    return xi.effect.EVASION_DOWN
end

return abilityObject
