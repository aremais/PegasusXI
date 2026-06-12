-----------------------------------
-- Zone: Maze of Shakhrami (198)
-----------------------------------
local ID = zones[xi.zone.MAZE_OF_SHAKHRAMI]
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    if math.random(1, 100) <= 50 then
        DisallowRespawn(ID.mob.LEECH_KING, true)
        DisallowRespawn(ID.mob.ARGUS, false)
        xi.mob.updateNMSpawnPoint(ID.mob.ARGUS)
        local argus = GetMobByID(ID.mob.ARGUS)
        if argus then
            argus:setRespawnTime(math.random(900, 7200))
        end
    else
        DisallowRespawn(ID.mob.ARGUS, true)
        DisallowRespawn(ID.mob.LEECH_KING, false)
        xi.mob.updateNMSpawnPoint(ID.mob.LEECH_KING)
        local leechKing = GetMobByID(ID.mob.LEECH_KING)
        if leechKing then
            leechKing:setRespawnTime(math.random(900, 7200))
        end
    end

    xi.treasure.initZone(zone)
    xi.helm.initZone(zone, xi.helmType.EXCAVATION)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-345, -11, -180, 239)
    end

    return cs
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
