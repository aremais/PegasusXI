-----------------------------------
-- Conflag Strike
-- Family: Ifrit (Player Pet)
-- Notes: Stage 4 magical fire damage. Single target. Blood Pact: Rage.
--        Per BG-Wiki, also applies a strong Burn (~30 HP/tick, INT-63, 60s).
-- Reference: https://www.bg-wiki.com/ffxi/Conflag_Strike
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local params = {}

    params.baseDamage      = pet:getMainLvl() + 2
    params.fTP             = { 5.3570, 8.0273, 10.7031 }
    params.int_wSC         = 0.30
    params.element         = xi.element.FIRE
    params.attackType      = xi.attackType.MAGICAL
    params.damageType      = xi.damageType.FIRE
    params.shadowBehavior  = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    params.dStatMultiplier = 1.5
    params.canMagicBurst   = true
    params.primaryMessage  = xi.msg.basic.USES_JA_TAKE_DAMAGE

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- Apply Burn on hit (no separate resist roll; the magical hit roll already gated this).
        target:delStatusEffect(xi.effect.BURN)
        target:addStatusEffect(xi.effect.BURN, { power = 30, duration = 60, subPower = 63, tick = 3, origin = pet })
    end

    return info.damage
end

return abilityObject
