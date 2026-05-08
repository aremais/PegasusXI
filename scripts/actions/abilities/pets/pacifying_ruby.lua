-----------------------------------
-- Pacifying Ruby
-- Family: Carbuncle (Player Pet)
-- Notes: Lv99 Blood Pact: Ward. Reduces enmity of target party member.
--        Per BG-Wiki: percent enmity removed scales with summoning skill.
-- Reference: https://www.bg-wiki.com/ffxi/Pacifying_Ruby
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    -- Cannot reduce enmity for non-player targets.
    if not target:isPC() then
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return
    end

    -- Percent of enmity to shed. Baseline 50% with a small scale from summoning skill over cap (max +30%).
    local skillOverCap   = xi.summon.getSummoningSkillOverCap(pet)
    local percentToLower = utils.clamp(50 + math.floor(skillOverCap / 2), 50, 80)

    -- Iterate every mob that has the target on its enmity list and reduce their accumulated enmity.
    -- Pattern mirrors xi.job_utils.dragoon.useSuperJump (scripts/globals/job_utils/dragoon.lua).
    local notorietyList = target:getNotorietyList()
    local affected      = 0

    for _, mob in pairs(notorietyList) do
        if mob:isMob() then
            mob:lowerEnmity(target, percentToLower)
            affected = affected + 1
        end
    end

    if affected > 0 then
        -- "<user> uses <ability>. <target>'s enmity decreases."
        petskill:setMsg(xi.msg.basic.JA_ENMITY_DECREASE)
    else
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
    end

    return 0
end

return abilityObject
