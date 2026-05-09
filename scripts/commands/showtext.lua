-----------------------------------
-- func: showtext
-- desc: Sends a showText packet from the cursor target for probing zone text IDs.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local maxRange = 50

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!showtext <message ID> (end ID) (delay ms)')
    player:printToPlayer('Target an NPC first. Example: !showtext 7330 7350 1500')
end

local function sendShowText(player, target, msgId)
    player:printToPlayer(string.format('showText ID: %u', msgId), xi.msg.channel.SYSTEM_3)
    player:showText(target, msgId)
end

commandObj.onTrigger = function(player, arg)
    if arg == nil then
        error(player, 'You must provide a message ID.')
        return
    end

    local target = player:getCursorTarget()
    if target == nil then
        error(player, 'Target an NPC first.')
        return
    end

    local args = utils.splitArg(arg)
    local startId = tonumber(args[1])
    local endId = tonumber(args[2]) or startId
    local delay = tonumber(args[3]) or 1500

    if startId == nil then
        error(player, 'Message ID must be a number.')
        return
    end

    if endId < startId then
        error(player, 'End ID must be greater than or equal to the start ID.')
        return
    end

    local count = endId - startId + 1
    if count > maxRange then
        error(player, string.format('Range is too large. Maximum range is %u IDs.', maxRange))
        return
    end

    delay = utils.clamp(delay, 500, 10000)

    for i = 0, count - 1 do
        local msgId = startId + i
        player:timer(i * delay, function(playerArg)
            sendShowText(playerArg, target, msgId)
        end)
    end
end

return commandObj
