-----------------------------------
-- Blindside
-- Avatar: Diabolos
-- Level: 99
-- Blood Pact: Rage
-- Single-hit physical slashing attack. Damage varies with TP.
-- Skillchain: Gravitation / Transfixion
-- Stat Mod: Avatar's STR & MND
-- https://www.bg-wiki.com/ffxi/Blindside
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local numhits = 1
    local accmod  = 1
    local dmgmod  = 5.0

    local info        = xi.summon.avatarPhysicalMove(pet, target, petskill, numhits, accmod, dmgmod, 0, xi.mobskills.physicalTpBonus.DMG_VARIES, 1.0, 1.5, 2.0)
    local totaldamage = xi.summon.avatarFinalAdjustments(info, pet, petskill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, numhits)

    target:takeDamage(totaldamage, pet, xi.attackType.PHYSICAL, xi.damageType.SLASHING)
    target:updateEnmityFromDamage(pet, totaldamage)

    return totaldamage
end

return abilityObject
