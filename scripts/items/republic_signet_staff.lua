-----------------------------------
-- ID: 17583
-- Item: Republic Signet Staff
-- Effect: Signet
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    -- Equip/unequip checks pass nil caster; treat user as target.
    local user = caster or target

    if target:getNation() ~= xi.nation.BASTOK then
        return xi.msg.basic.ITEM_CANNOT_USE_ON
    end

    -- If target's current region is not a conquest region or not a nation city involved with conquest
    if target:getCurrentRegion() > xi.region.JEUNO then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    -- Can only use on targets within party or self
    if target:getID() ~= user:getID() then
        if
            user:getPartyLeader() == nil or
            target:getPartyLeader():getID() ~= user:getPartyLeader():getID()
        then
            return xi.msg.basic.ITEM_CANNOT_USE_ON
        end
    end

    return 0
end

itemObject.onItemUse = function(target, user)
    target:delStatusEffectsByFlag(xi.effectFlag.INFLUENCE, true)
    target:addStatusEffect(xi.effect.SIGNET, { duration = 18000, origin = user })
end

return itemObject
