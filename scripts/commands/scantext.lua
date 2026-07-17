-----------------------------------
-- func: scantext
-- desc: Scans showText IDs from the cursor target, defaulting around the current zone's NOMAD_MOOGLE_DIALOG.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local defaultRadius = 25
local maxRange = 100

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!scantext')
    player:printToPlayer('!scantext <radius>')
    player:printToPlayer('!scantext <start ID> <end ID> (delay ms)')
end

local function getNomadDialogId(player)
    local zoneData = zones[player:getZoneID()]
    if zoneData == nil or zoneData.text == nil then
        return nil
    end

    return zoneData.text.NOMAD_MOOGLE_DIALOG
end

local function sendShowText(player, target, msgId)
    player:printToPlayer(string.format('showText ID: %u', msgId), xi.msg.channel.SYSTEM_3)
    player:showText(target, msgId)
end

commandObj.onTrigger = function(player, arg)
    local target = player:getCursorTarget()
    if target == nil then
        error(player, 'Target an NPC first.')
        return
    end

    local startId
    local endId
    local delay = 1500
    local args = arg ~= nil and utils.splitArg(arg) or {}

    if args[1] == nil then
        local centerId = getNomadDialogId(player)
        if centerId == nil then
            error(player, 'Current zone has no NOMAD_MOOGLE_DIALOG value. Use !scantext <start ID> <end ID> instead.')
            return
        end

        startId = math.max(0, centerId - defaultRadius)
        endId = centerId + defaultRadius
    elseif args[2] == nil then
        local centerId = getNomadDialogId(player)
        local radius = tonumber(args[1])

        if centerId == nil then
            error(player, 'Current zone has no NOMAD_MOOGLE_DIALOG value. Use !scantext <start ID> <end ID> instead.')
            return
        elseif radius == nil then
            error(player, 'Radius must be a number.')
            return
        end

        radius = utils.clamp(radius, 0, math.floor(maxRange / 2))
        startId = math.max(0, centerId - radius)
        endId = centerId + radius
    else
        startId = tonumber(args[1])
        endId = tonumber(args[2])
        delay = tonumber(args[3]) or delay

        if startId == nil or endId == nil then
            error(player, 'Start ID and end ID must be numbers.')
            return
        end
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
    player:printToPlayer(string.format('Scanning showText IDs %u-%u on %s.', startId, endId, target:getName()), xi.msg.channel.SYSTEM_3)

    for i = 0, count - 1 do
        local msgId = startId + i
        player:timer(i * delay, function(playerArg)
            sendShowText(playerArg, target, msgId)
        end)
    end
end

return commandObj
