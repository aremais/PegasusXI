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
        local soaMission = player:getCurrentMission(xi.mission.log_id.SOA)

        if
            soaMission == xi.mission.id.soa.ONWARD_TO_ADOULIN or
            soaMission == xi.mission.id.soa.HEARTWINGS_AND_THE_KINDHEARTED
        then
            if soaMission == xi.mission.id.soa.ONWARD_TO_ADOULIN then
                player:completeMission(xi.mission.log_id.SOA, xi.mission.id.soa.ONWARD_TO_ADOULIN)
                player:addMission(xi.mission.log_id.SOA, xi.mission.id.soa.HEARTWINGS_AND_THE_KINDHEARTED)
            end

            player:setPos(169.638, 0.491, -27.128, 207, xi.zone.CEIZAK_BATTLEGROUNDS)
            return
        end

        xi.waypoint.onTrigger(player, npc)
    else
        player:messageSpecial(ID.text.WAYPOINT_EXAMINE)
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
    if csid == 10121 then
        xi.waypoint.onEventUpdate(player, csid, option, npc)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 10121 then
        xi.waypoint.onEventFinish(player, csid, option, npc)
    end
end

return entity
