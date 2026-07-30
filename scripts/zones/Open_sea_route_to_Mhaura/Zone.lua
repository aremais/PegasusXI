-----------------------------------
-- Zone: Open_sea_route_to_Mhaura (47)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        local position = math.randomInt(-2, 2) + 0.150
        player:setPos(position, -2.100, 3.250, 64)
    end

    return cs
end

zoneObject.onTransportEvent = function(player, prevZoneId, transportId)
    player:startEvent(1028)
    player:printToPlayer('We are now docking in Mhaura.', xi.msg.channel.SYSTEM_3)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
    if csid == 1028 then
        player:setPos(0, 0, 0, 0, xi.zone.MHAURA)
    end
end

return zoneObject
