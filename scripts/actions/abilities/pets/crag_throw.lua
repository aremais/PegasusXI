-----------------------------------
-- Crag Throw M=8
-- Family: Titan (Player Pet)
-- Notes: Lv99 Blood Pact: Rage. Single-target physical earth damage with
--        a follow-up Slow effect.
--        Per BG-Wiki: inflicts 30% Slow for 2 minutes; not actually a
--        Ranged Attack despite the help text; accuracy bonus varies with TP.
--        Stat mod: STR & AGI. Skillchain: Gravitation / Scission.
-- Reference: https://www.bg-wiki.com/ffxi/Crag_Throw
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local numhits          = 1
    local accmod           = 1
    local dmgmod           = 8
    local dmgmodsubsequent = 0

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local info        = xi.summon.avatarPhysicalMove(pet, target, petskill, numhits, accmod, dmgmod, dmgmodsubsequent, xi.mobskills.magicalTpBonus.NO_EFFECT, 1, 2, 3)
    local totaldamage = xi.summon.avatarFinalAdjustments(info, pet, petskill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, numhits)

    target:takeDamage(totaldamage, pet, xi.attackType.PHYSICAL, xi.damageType.SLASHING)
    target:updateEnmityFromDamage(pet, totaldamage)

    -- 30% Slow for 2 minutes on hit.
    if info.hitslanded > 0 then
        target:delStatusEffect(xi.effect.SLOW)
        target:addStatusEffect(xi.effect.SLOW, { power = 3000, duration = 120, origin = pet, tier = 3 })
    end

    return totaldamage
end

return abilityObject
