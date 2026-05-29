-----------------------------------
-- Zone: VeLugannon_Palace (177)
-----------------------------------
local ID = zones[xi.zone.VELUGANNON_PALACE]
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.treasure.initZone(zone)
    SetServerVariable('[POP]SteamCleaner', 0) -- should 'reset' on server repop

    local qm1Id = ID.npc.QM1
    if not qm1Id then
        return
    end

    local curtanaQm = GetNPCByID(qm1Id)

    -- Move Curtana to random position on zone load
    if curtanaQm and ID.positions and ID.positions.curtana then
        curtanaQm:setPos(unpack(ID.positions.curtana[math.random(1, #ID.positions.curtana)]))
    end
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-100.01, -25.752, -399.468, 59)
    end

    return cs
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
