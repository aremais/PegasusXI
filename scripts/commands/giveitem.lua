-----------------------------------
-- func: giveitem <player> <itemId> <amount> <aug1> <v1> <aug2> <v2> <aug3> <v3> <aug4> <v4>
-- desc: Gives an item to the target player.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'siiiiiiiiii'
}

commandObj.onTrigger = function(player, target, itemId, amount, aug0, aug0val, aug1, aug1val, aug2, aug2val, aug3, aug3val)
    if target == nil or itemId == nil then
        player:printToPlayer('You must enter a valid player name and item ID.')
        return
    end

    local targ = GetPlayerByName(target)
    if targ == nil then
        player:printToPlayer(string.format('Player named "%s" not found!', target))
        return
    end

    local ID = zones[targ:getZoneID()]

    if targ:getFreeSlotsCount() == 0 then
        targ:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, itemId)
        player:printToPlayer(string.format('Player \'%s\' does not have free space for that item!', target))
        return
    end

    if not amount or amount < 1 then
        amount = 1
    end

    local itemProto = GetItemByID(itemId)
    if not itemProto then
        player:printToPlayer(string.format('Item ID %u is not in the item database.', itemId))
        return
    end

    local itemData =
    {
        id       = itemId,
        quantity = amount,
        silent   = true,
    }

    local hasExdata = false
    local augments  = {}
    local augmentPairs =
    {
        { aug0, aug0val },
        { aug1, aug1val },
        { aug2, aug2val },
        { aug3, aug3val },
    }

    for _, augmentData in ipairs(augmentPairs) do
        local augmentId = augmentData[1]
        if augmentId ~= nil and augmentId > 0 then
            hasExdata = true
            table.insert(augments, { id = augmentId, value = augmentData[2] or 0 })
        end
    end

    if hasExdata then
        itemData.exdata =
        {
            augmentKind    = xi.augment.kind.HAS_AUGMENTS,
            augmentSubKind = xi.augment.subKind.STANDARD,
            augments       = augments,
        }
    end

    local countBefore = targ:getItemCount(itemId)
    local obtained    = targ:addItem(itemData)
    local countAfter  = targ:getItemCount(itemId)
    local added       = countAfter - countBefore

    if not obtained or added <= 0 then
        player:printToPlayer(string.format('Failed to give item %u to %s.', itemId, target))
        return
    end

    if type(targ.messageItemObtained) == 'function' and targ:messageItemObtained(itemId, amount) then
        -- retail obtain packet sent
    elseif amount > 1 then
        targ:printToPlayer(string.format('You obtain %u x %s!', amount, itemProto:getName()), xi.msg.channel.SYSTEM_3)
    else
        targ:printToPlayer(string.format('Obtained: %s.', itemProto:getName()), xi.msg.channel.SYSTEM_3)
    end

    player:printToPlayer(string.format('Gave %u x %s (ID %u) to %s.', added, itemProto:getName(), itemId, target))
end

return commandObj
