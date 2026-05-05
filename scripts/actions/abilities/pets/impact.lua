-----------------------------------
-- Impact (Blood Pact)
-- Family: Fenrir (Player Pet)
-- Notes: Lv99 Blood Pact: Rage. Deals dark damage that lowers an enemy's
--        strength, dexterity, vitality, agility, intelligence, mind, and charisma.
--        Potency varies with summoning skill: approximately -floor(skill/20) to all stats.
--        Pet TP adds to damage, similar to merit blood pacts.
-- Reference: https://www.bg-wiki.com/ffxi/Impact_(Blood_Pact)
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
    params.fTP             = { 5.0, 7.5, 9.0 }
    params.int_wSC         = 0.30
    params.element         = xi.element.DARK
    params.attackType      = xi.attackType.MAGICAL
    params.damageType      = xi.damageType.DARK
    params.shadowBehavior  = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    params.dStatMultiplier = 1.5
    params.canMagicBurst   = true
    params.primaryMessage  = xi.msg.basic.USES_JA_TAKE_DAMAGE

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    -- Apply stat-down effects. Potency ~= floor(summoningSkill / 20).
    local skill    = summoner:getSkillLevel(xi.skill.SUMMONING_MAGIC)
    local power    = math.floor(skill / 20)
    local duration = 180

    local effectTable =
    {
        xi.effect.STR_DOWN,
        xi.effect.DEX_DOWN,
        xi.effect.VIT_DOWN,
        xi.effect.AGI_DOWN,
        xi.effect.INT_DOWN,
        xi.effect.MND_DOWN,
        xi.effect.CHR_DOWN,
    }

    for _, effectId in ipairs(effectTable) do
        if not target:hasStatusEffect(effectId) then
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = pet })
        end
    end

    return info.damage
end

return abilityObject
