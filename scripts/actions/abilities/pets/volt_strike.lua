-----------------------------------
-- Volt Strike M=10 subsequent hits M=2
-- Family: Ramuh (Player Pet)
-- Notes: Lv99 Blood Pact: Rage. Threefold physical attack that stuns the target.
--        Stat mod: STR & INT. Skillchain: Fragmentation / Scission.
-- Reference: https://www.bg-wiki.com/ffxi/Volt_Strike
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local numhits          = 3
    local accmod           = 1
    local dmgmod           = 10
    local dmgmodsubsequent = 2

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local info        = xi.summon.avatarPhysicalMove(pet, target, petskill, numhits, accmod, dmgmod, dmgmodsubsequent, xi.mobskills.magicalTpBonus.NO_EFFECT, 1, 2, 3)
    local totaldamage = xi.summon.avatarFinalAdjustments(info, pet, petskill, target, xi.attackType.PHYSICAL, xi.damageType.BLUNT, numhits)

    -- Stun on hit. Per BG-Wiki: 15-second unresisted stun.
    if info.hitslanded > 0 then
        target:delStatusEffect(xi.effect.STUN)
        target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 15, origin = pet })
    end

    target:takeDamage(totaldamage, pet, xi.attackType.PHYSICAL, xi.damageType.BLUNT)
    target:updateEnmityFromDamage(pet, totaldamage)

    return totaldamage
end

return abilityObject
