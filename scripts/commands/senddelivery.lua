-----------------------------------
-- func: senddelivery <player> <itemid> [quantity] [sender]
-- desc: Drops an item (or gil = 65535) into a player's delivery box (the
--       "receive" side, box 1). Wraps the engine global SendItemToDeliveryBox,
--       so it resolves the target by name from the DB and works on OFFLINE
--       players too (no inventory space needed, unlike !giveitem).
--
--       Used by GMAss's "Delivery Box" tab -> Send to Box button.
--
--       Notes / sharp edges:
--         * Quantity is clamped to ONE stack by the engine. For multiple
--           stacks, run the command again AFTER the player has opened their
--           delivery box (the engine always inserts at slot 0; opening the box
--           reassigns real slots and frees slot 0 for the next send).
--         * sender defaults to the GM's name; pass a 4th arg to brand it
--           (e.g. an event name). Single token, no spaces.
--
--       Place in: scripts/commands/senddelivery.lua  (NEW file -> full xi_map restart)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'siis'
}

commandObj.onTrigger = function(player, name, itemId, quantity, sender)
    if name == nil or itemId == nil then
        player:printToPlayer('Usage: !senddelivery <player> <itemid> [quantity] [sender]')
        return
    end

    quantity = quantity or 1
    if quantity < 1 then quantity = 1 end
    sender = (sender ~= nil and sender ~= '') and sender or player:getName()

    -- SendItemToDeliveryBox(playerName, itemId, quantity, senderText)
    -- returns: 0 SUCCESS, 1 SUCCESS_LIMITED_TO_STACK_SIZE,
    --          2 PLAYER_NOT_FOUND, 3 ITEM_NOT_FOUND, 4 QUERY_ERROR
    local rc = SendItemToDeliveryBox(name, itemId, quantity, sender)

    if rc == 0 then
        player:printToPlayer(string.format('Sent item %d x%d to %s\'s delivery box (from "%s").', itemId, quantity, name, sender))
    elseif rc == 1 then
        player:printToPlayer(string.format('Sent item %d to %s\'s delivery box (capped to one stack).', itemId, name))
    elseif rc == 2 then
        player:printToPlayer(string.format('senddelivery: player "%s" not found.', name))
    elseif rc == 3 then
        player:printToPlayer(string.format('senddelivery: item %d not found.', itemId))
    else
        player:printToPlayer('senddelivery: delivery failed (query error). Their delivery box may already have a pending slot-0 item; have them open it first.')
    end
end

return commandObj
