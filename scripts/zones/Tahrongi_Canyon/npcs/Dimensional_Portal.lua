-----------------------------------
-- Area: Tahrongi_Canyon
--  NPC: Dimensional_Portal
-- !pos 260.000 35.150 340.000 117
-----------------------------------
local ID = zones[xi.zone.TAHRONGI_CANYON]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.SONG_OF_HOPE) then
        player:setPos(605.200, -372.000, -957.800, 225, xi.zone.REISENJIMA)
        return
    end

    if player:getCurrentMission(xi.mission.log_id.COP) > xi.mission.id.cop.THE_WARRIORS_PATH then
        player:startEvent(915)
    else
        player:messageSpecial(ID.text.ALREADY_OBTAINED_TELE + 1) -- Telepoint Disappeared
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 915 and option == 1 then
        player:setPos(654.200, -2.799, 100.700, 193, 33) -- To AlTaieu (R)
    end
end

return entity
