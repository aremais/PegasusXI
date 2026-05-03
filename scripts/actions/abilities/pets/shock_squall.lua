-----------------------------------
-- Shock Squall
-- Family: Ramuh (Player Pet)
-- Notes: Lv92 Blood Pact: Ward. Temporarily prevents all enemies within
--        area of effect from acting (AoE Stun).
--        Per BG-Wiki: 15-second unresisted stun, 10' radius, wide AoE.
--        Resistance builds quickly on many NMs; cannot refresh an
--        existing stun.
-- Reference: https://www.bg-wiki.com/ffxi/Shock_Squall
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    -- Cannot refresh / overwrite an existing Stun (per BG-Wiki notes).
    if
        xi.data.statusEffect.isTargetImmune(target, xi.effect.STUN, xi.element.THUNDER) or
        xi.data.statusEffect.isTargetResistant(pet, target, xi.effect.STUN) or
        xi.data.statusEffect.isEffectNullified(target, xi.effect.STUN, 0) or
        target:hasStatusEffect(xi.effect.STUN)
    then
        if target:getID() == action:getPrimaryTargetID() then
            petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        else
            petskill:setMsg(xi.msg.basic.NO_EFFECT)
        end

        return xi.effect.STUN
    end

    -- Magic accuracy resist roll. Stun resistance builds quickly on NMs.
    local bonus  = xi.summon.getSummoningSkillOverCap(pet)
    local resist = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.THUNDER, xi.mod.INT, xi.effect.STUN, bonus)
    if resist < 0.5 then
        petskill:setMsg(xi.msg.basic.JA_MISS_2) -- resist message
        return xi.effect.STUN
    end

    -- 15s base stun unresisted, scaled down by resist tier (15s, 7s, 3s, 1s).
    local duration = math.max(1, math.floor(15 * resist))

    target:addStatusEffect(xi.effect.STUN, { power = 1, duration = duration, origin = pet })
    if target:getID() == action:getPrimaryTargetID() then
        petskill:setMsg(xi.msg.basic.JA_RECEIVES_EFFECT_2)
    else
        petskill:setMsg(xi.msg.basic.JA_RECEIVES_EFFECT)
    end

    target:updateEnmity(pet)

    return xi.effect.STUN
end

return abilityObject
