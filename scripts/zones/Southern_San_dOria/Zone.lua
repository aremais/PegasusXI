-----------------------------------
-- Zone: Southern_San_dOria (230)
-----------------------------------
require('scripts/quests/flyers_for_regine')
local ID = zones[xi.zone.SOUTHERN_SAN_DORIA]
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    local repairer = GetNPCByID(ID.npc.REPAIRER_MOOGLE)
    if repairer then
        repairer:renameEntity('Repairer Moogle', true)
    end

    zone:registerCuboidTriggerArea(1, -292, -10, 90 , -258, 10, 105)
    quests.ffr.initZone(zone) -- register trigger areas 2 through 6
    xi.events.harvestFestival.applyHalloweenNpcCostumes(zone:getID())
    xi.chocobo.initZone(zone)
    xi.chocoboGame.clearRecord(zone)
    xi.conquest.toggleRegionalNPCs(zone)
    xi.events.eggHunt.onZoneInitialize(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    return xi.moghouse.onMoghouseZoneEvent(player, prevZone)
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
    quests.ffr.onTriggerAreaEnter(player, triggerArea) -- player approaching Flyers for Regine NPCs
end

zoneObject.onTriggerAreaLeave = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
