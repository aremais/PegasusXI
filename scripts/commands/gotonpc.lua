-----------------------------------
-- func: gotonpc
-- desc: Teleport to an NPC by name (global) or npcid (any zone). GM4+.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 4,
    parameters = 'si',
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!gotonpc <npc name or npcid> (index)')
end

local function coordsAreValid(x, y, z)
    return not (x == 0 and y == 0 and z == 0)
end

local function gotoNpcRecord(player, record)
    local x     = record.x
    local y     = record.y
    local z     = record.z
    local rot   = record.rot
    local name  = record.name
    local npcid = record.npcid
    local zoneId = record.zoneId
    local zoneName = record.zoneName

    local targ = GetNPCByID(npcid)
    if targ then
        local pos = targ:getPos()
        if coordsAreValid(pos.x, pos.y, pos.z) then
            x   = pos.x
            y   = pos.y
            z   = pos.z
            rot = targ:getRotPos()
            zoneId = targ:getZoneID()
            zoneName = targ:getZoneName()
        end
    end

    local gotoZone = nil
    if zoneId ~= player:getZoneID() then
        gotoZone = zoneId
    end

    player:printToPlayer(string.format('Going to %s (%i) in %s.', name, npcid, zoneName))
    player:timer(500, function(playerArg)
        playerArg:setPos(x, y, z, rot, gotoZone)
    end)
end

local function findNpcsByPattern(player, pattern)
    local matches = {}

    if FindNPCsByName and type(FindNPCsByName) == "function" then
        for _, record in pairs(FindNPCsByName(pattern)) do
            table.insert(matches, record)
        end
        return matches
    end

    -- Fallback when map has not been rebuilt with FindNPCsByName (current zone only).
    local zone = player:getZone()
    if not zone then
        return matches
    end

    for _, entity in pairs(zone:queryEntitiesByName(pattern)) do
        if entity:isNPC() then
            local pos = entity:getPos()
            if coordsAreValid(pos.x, pos.y, pos.z) then
                table.insert(matches, {
                    npcid    = entity:getID(),
                    name     = entity:getName(),
                    zoneId   = entity:getZoneID(),
                    zoneName = entity:getZoneName(),
                    x        = pos.x,
                    y        = pos.y,
                    z        = pos.z,
                    rot      = entity:getRotPos(),
                })
            end
        end
    end

    return matches
end

local function gotoNpcId(player, npcid)
    local targ = GetNPCByID(npcid)
    if targ then
        local pos = targ:getPos()
        if not coordsAreValid(pos.x, pos.y, pos.z) then
            player:printToPlayer(string.format('%s (%i) has not been given coordinates.', targ:getName(), npcid))
            return
        end

        gotoNpcRecord(player, {
            npcid    = npcid,
            name     = targ:getName(),
            zoneId   = targ:getZoneID(),
            zoneName = targ:getZoneName(),
            x        = pos.x,
            y        = pos.y,
            z        = pos.z,
            rot      = targ:getRotPos(),
        })
        return
    end

    player:printToPlayer(string.format('NPC %i not loaded on this process; requesting warp.', npcid))
    player:gotoEntity(npcid)
end

commandObj.onTrigger = function(player, pattern, index)
    if pattern == nil or pattern == '' then
        error(player, 'You must enter an NPC name or npcid.')
        return
    end

    local npcid = tonumber(pattern)
    if npcid then
        gotoNpcId(player, npcid)
        return
    end

    local matches = findNpcsByPattern(player, pattern)

    if #matches == 0 then
        if not FindNPCsByName or type(FindNPCsByName) ~= "function" then
            player:printToPlayer(string.format('No NPCs named "%s" in this zone. Rebuild xi_map for world-wide search, or use !gotonpc <npcid>.', pattern))
        else
            player:printToPlayer(string.format('No NPCs found matching "%s".', pattern))
        end
        return
    end

    if index ~= nil and index > 0 and index <= #matches then
        gotoNpcRecord(player, matches[index])
        return
    end

    if #matches == 1 then
        gotoNpcRecord(player, matches[1])
        return
    end

    player:printToPlayer('Multiple NPCs found. Use !gotonpc <name> <index> to choose:', xi.msg.channel.SYSTEM_3)
    for i, record in ipairs(matches) do
        player:printToPlayer(
            string.format('[%d] %s (%i) in %s', i, record.name, record.npcid, record.zoneName),
            xi.msg.channel.SYSTEM_3
        )
    end
end

return commandObj
