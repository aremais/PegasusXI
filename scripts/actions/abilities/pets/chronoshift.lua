-----------------------------------
-- Chronoshift
-- Avatar: Atomos only
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    -- Chronoshift is automatically performed by Atomos when summoned.
    -- It cannot be triggered manually under any circumstances.
    return xi.msg.basic.UNABLE_TO_USE_JA2, 0
end

abilityObject.onPetAbility = function(target, pet, petskill, summoner, action)
    local effectCount = 0
    local effectID    = pet:getLocalVar('aEffectID') or 0    -- Retrive the absorbed effect's ID
    local effect      = pet:getStatusEffect(effectID) or nil -- Find that effect on Atomos

    if effect then
        -- Delete old effect if on target already
        target:delStatusEffectSilent(effectID)
        -- Add the stolen effect to the party
        target:copyStatusEffect(effect)
        petskill:setMsg(xi.msg.basic.RECEIVE_MAGICAL_EFFECT)
        effectCount = 1
    else
        petskill:setMsg(xi.msg.basic.NO_EFFECT)
    end

    pet:timer(5000, function()
        if summoner then
            summoner:despawnPet()
        end
    end)

    return effectCount
end

return abilityObject
