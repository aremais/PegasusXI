-----------------------------------
-- func: additem <itemId> <quantity> <aug1> <v1> <aug2> <v2> <aug3> <v3> <aug4> <v4> <trial>
-- desc: Adds an item to the GMs inventory.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'siiiiiiiiii'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!additem <itemId> (quantity) (aug1) (v1) (aug2) (v2) (aug3) (v3) (aug4) (v4) (trial)')
end

local function showItemObtained(player, itemId, quantity)
    if player:messageItemObtained(itemId, quantity) then
        return
    end

    local ID = zones[player:getZoneID()]
    if not ID or not ID.text or not ID.text.ITEM_OBTAINED then
        return
    end

    if quantity > 1 then
        local pluralMsg = ID.text.ITEMS_OBTAINED or (ID.text.ITEM_OBTAINED + 9)
        player:messageSpecial(pluralMsg, itemId, quantity)
    else
        player:messageSpecial(ID.text.ITEM_OBTAINED, itemId)
    end
end

commandObj.onTrigger = function(player, item, quantity, aug0, aug0val, aug1, aug1val, aug2, aug2val, aug3, aug3val, trialId)
    if item == nil then
        error(player, 'No Item ID given.')
        return
    end

    local itemToGet = 0
    local dataType  = tonumber(item)

    if dataType == nil then
        local retItem = GetItemIDByName(tostring(item))
        if retItem > 0 and retItem < 65000 then
            itemToGet = retItem
        elseif retItem >= 65000 then
            player:printToPlayer(string.format('Found %s instances matching "%s". Use ID or exact name.', 65536 - retItem, tostring(item)))
            return
        else
            player:printToPlayer(string.format('Item %s not found in database.', item))
            return
        end
    else
        itemToGet = dataType
    end

    if itemToGet == 0 then
        error(player, 'Item not found.')
        return
    end

    local zoneId = player:getZoneID()
    local ID     = zones[zoneId]
    if not ID or not ID.text then
        error(player, string.format('Zone text IDs are not loaded for zone %u.', zoneId))
        return
    end

    if not quantity or quantity < 1 then
        quantity = 1
    end

    local itemProto = GetItemByID(itemToGet)
    if not itemProto then
        player:printToPlayer(string.format('Item ID %u is not in the item database.', itemToGet))
        return
    end

    if itemProto:isType(xi.itemType.CURRENCY) then
        player:printToPlayer(string.format('Item ID %u is currency. Use !givegil instead.', itemToGet))
        return
    end

    if player:getFreeSlotsCount() == 0 then
        player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, itemToGet)
        return
    end

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

    if trialId ~= nil and trialId > 0 then
        hasExdata = true
    end

    local itemData =
    {
        id       = itemToGet,
        quantity = quantity,
        silent   = true,
    }

    if hasExdata then
        itemData.exdata =
        {
            augmentKind    = xi.augment.kind.HAS_AUGMENTS,
            augmentSubKind = xi.augment.subKind.STANDARD,
        }

        if #augments > 0 then
            itemData.exdata.augments = augments
        end

        if trialId ~= nil and trialId > 0 then
            itemData.exdata.augmentSubKind = itemData.exdata.augmentSubKind + xi.augment.subKind.TRIAL
            itemData.exdata.trial          = { id = trialId, completed = false }
        end
    end

    local itemFlags = GetItemFlagsByID(itemToGet)
    if bit.band(itemFlags, xi.itemFlag.RARE) ~= 0 then
        -- Rare items cannot be duplicated; remove any existing copy from all bags first.
        for i = xi.inv.INVENTORY, xi.inv.WARDROBE8 do
            while player:hasItem(itemToGet, i) do
                player:delItem(itemToGet, 1, i)
            end
        end
    end

    local countBefore = player:getItemCount(itemToGet)
    local obtained    = player:addItem(itemData)
    local countAfter  = player:getItemCount(itemToGet)

    if not obtained or countAfter <= countBefore then
        if player:getFreeSlotsCount() == 0 then
            player:printToPlayer(string.format(
                'Failed to add item %u (%s): main inventory has no free slots.',
                itemToGet,
                itemProto:getName()
            ))
        else
            player:printToPlayer(string.format(
                'Failed to add item %u (%s). Check server logs for database errors.',
                itemToGet,
                itemProto:getName()
            ))
        end

        return
    end

    local added = countAfter - countBefore
    showItemObtained(player, itemToGet, added)
end

return commandObj
