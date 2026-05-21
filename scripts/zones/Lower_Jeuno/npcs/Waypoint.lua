-----------------------------------
-- Area: Lower Jeuno (245)
--  NPC: Waypoint
--  SoA: Waypoint
-- !pos 20 -34.922 0.000 245
-----------------------------------
local ID = zones[xi.zone.LOWER_JEUNO]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.waypoint.onTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.ADOULINIAN_CHARTER_PERMIT) then
        if player:getCurrentMission(xi.mission.log_id.SOA) == xi.mission.id.soa.ONWARD_TO_ADOULIN then
            player:completeMission(xi.mission.log_id.SOA, xi.mission.id.soa.ONWARD_TO_ADOULIN)
            player:addMission(xi.mission.log_id.SOA, xi.mission.id.soa.HEARTWINGS_AND_THE_KINDHEARTED)
            player:setPos(169.638, 0.491, -27.128, 207, xi.zone.CEIZAK_BATTLEGROUNDS)
            return
        end

        xi.waypoint.onTrigger(player, npc)
    else
        player:messageSpecial(ID.text.WAYPOINT_EXAMINE)
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.waypoint.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.waypoint.onEventFinish(player, csid, option, npc)
end

return entity
