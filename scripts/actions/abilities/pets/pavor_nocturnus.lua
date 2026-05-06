-----------------------------------
-- Pavor Nocturnus
-- Avatar: Diabolos
-- Level: 98
-- Blood Pact: Ward
-- Attempts to inflict Death on the target. If Death misses, attempts to Dispel instead.
-- Death success rate is very high on sleeping targets, near-zero on awake targets.
-- Does not attempt Death on Notorious Monsters; falls through to Dispel only.
-- https://www.bg-wiki.com/ffxi/Pavor_Nocturnus
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local deathLanded = false

    -- Death does not function on Notorious Monsters
    if not target:isNM() then
        local isSleeping = target:hasStatusEffect(xi.effect.SLEEP_I) or target:hasStatusEffect(xi.effect.SLEEP_II)

        if isSleeping then
            -- Very high success rate on sleeping targets, scaled by summoning skill overcap
            local bonusMacc  = xi.summon.getSummoningSkillOverCap(pet)
            local resistRate = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.DARK, xi.mod.INT, xi.effect.SLEEP_I, bonusMacc)

            -- resistRate of 1.0 = no resistance; we treat anything >= 0.5 as Death landing
            if resistRate >= 0.5 then
                deathLanded = true
            end
        else
            -- Near-zero chance on awake targets (~3%)
            if math.random(1, 100) <= 3 then
                deathLanded = true
            end
        end
    end

    if deathLanded then
        petskill:setMsg(xi.msg.basic.SKILL_ENFEEB_IS)
        target:takeDamage(target:getHP(), pet, xi.attackType.MAGICAL, xi.damageType.DARK)
        return xi.effect.KO
    end

    -- Death failed (or was skipped on NM): attempt Dispel
    local dispelledEffect = target:dispelStatusEffect()

    if dispelledEffect ~= xi.effect.NONE then
        petskill:setMsg(xi.msg.basic.NONE)
        return dispelledEffect
    else
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return 0
    end
end

return abilityObject
