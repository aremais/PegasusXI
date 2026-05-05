-----------------------------------
-- Heavenward Howl
-- Family: Fenrir (Player Pet)
-- Notes: Lv96 Blood Pact: Ward. Grants the effect of HP Drain or MP Drain
--        to party members within area of effect. Which effect and its potency
--        depend on the current moon phase. Endrain is active near full moon;
--        Enaspir is active near new moon.
--
--        Endrain potency by phase:
--          First Quarter      5%
--          Waxing Gibbous     8% / 12%
--          Full Moon         15%
--          Waning Gibbous    12% /  8%
--
--        Enaspir potency by phase:
--          Last Quarter       1%
--          Waning Crescent    2% /  4%
--          New Moon           5%
--          Waxing Crescent    4% /  2%
--
-- Reference: https://www.bg-wiki.com/ffxi/Heavenward_Howl
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

    local moonCycle = getVanadielMoonCycle()

    -- Maps moon phase -> { effect, potency% }
    local cycleEffects =
    {
        [xi.moonCycle.FIRST_QUARTER]           = { xi.effect.ENDRAIN, 5  },
        [xi.moonCycle.LESSER_WAXING_GIBBOUS]   = { xi.effect.ENDRAIN, 8  },
        [xi.moonCycle.GREATER_WAXING_GIBBOUS]  = { xi.effect.ENDRAIN, 12 },
        [xi.moonCycle.FULL_MOON]               = { xi.effect.ENDRAIN, 15 },
        [xi.moonCycle.GREATER_WANING_GIBBOUS]  = { xi.effect.ENDRAIN, 12 },
        [xi.moonCycle.LESSER_WANING_GIBBOUS]   = { xi.effect.ENDRAIN, 8  },
        [xi.moonCycle.THIRD_QUARTER]           = { xi.effect.ENASPIR, 1  },
        [xi.moonCycle.GREATER_WANING_CRESCENT] = { xi.effect.ENASPIR, 2  },
        [xi.moonCycle.LESSER_WANING_CRESCENT]  = { xi.effect.ENASPIR, 4  },
        [xi.moonCycle.NEW_MOON]                = { xi.effect.ENASPIR, 5  },
        [xi.moonCycle.LESSER_WAXING_CRESCENT]  = { xi.effect.ENASPIR, 4  },
        [xi.moonCycle.GREATER_WAXING_CRESCENT] = { xi.effect.ENASPIR, 2  },
    }

    local phaseData = cycleEffects[moonCycle]

    if phaseData == nil then
        -- Moon phase grants no effect
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return 0
    end

    local typeEffect = phaseData[1]
    local power      = phaseData[2]

    target:delStatusEffect(typeEffect)

    if target:addStatusEffect(typeEffect, { power = power, duration = duration, origin = pet }) then
        if target:getID() == action:getPrimaryTargetID() then
            petskill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT_2)
        else
            petskill:setMsg(xi.msg.basic.JA_GAIN_EFFECT)
        end
    else
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return 0
    end

    return typeEffect
end

return abilityObject
