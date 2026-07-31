-----------------------------------
-- Fleet Wind
-- Family: Garuda (Player Pet)
-- Notes: Lv86 Blood Pact: Ward. Increases movement speed for party members
--        within area of effect.
--        Per BG-Wiki: +20% Movement Speed (similar to Chocobo Mazurka),
--        base duration 2 minutes.
--
--        Implementation note: this reuses xi.effect.MAZURKA so Fleet Wind
--        respects the same engine cap (Mod::MOVE_SPEED_MAZURKA + Quickening
--        clamp 0-10 in CBattleEntity::UpdateSpeed). Power 8 ≈ +20% speed
--        from a 40 base. Re-applying will overwrite an existing Mazurka,
--        which mirrors retail behaviour for stacking movement-speed buffs.
-- Reference: https://www.bg-wiki.com/ffxi/Fleet_Wind
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local bonusTime = utils.clamp(summoner:getSkillLevel(xi.skill.SUMMONING_MAGIC) - 300, 0, 200)
    local duration  = 120 + bonusTime

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local typeEffect = xi.effect.MAZURKA
    target:delStatusEffect(typeEffect)

    if target:addStatusEffect(typeEffect, { power = 8, duration = duration, origin = pet }) then
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
