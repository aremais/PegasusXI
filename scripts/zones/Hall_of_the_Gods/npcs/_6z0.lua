-----------------------------------
-- Area: Hall of the Gods
--  NPC: Cermet Gate
-- Gives qualified players access to Ru'Aun Gardens.
-- !pos 0 -12 48 251
-----------------------------------
local ID = zones[xi.zone.HALL_OF_THE_GODS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.CERULEAN_CRYSTAL) then
        player:startEvent(2)
    elseif player:getCurrentMission(xi.mission.log_id.ZILART) == xi.mission.id.zilart.THE_TEMPLE_OF_DESOLATION then
        -- ZM10: CS 1 (onEventFinish is handled by the mission script).
        player:startEvent(1)
    elseif player:getCurrentMission(xi.mission.log_id.ZILART) == xi.mission.id.zilart.THE_HALL_OF_THE_GODS then
        -- ZM11 registers this gate as messageSpecial only (low priority). InteractionLookup alternates that
        -- with this NPC fallback, which would otherwise replay CS 1 here and show the wrong lines / junk text.
        player:messageSpecial(ID.text.DEPRESSION_A_CLUE)
    else
        player:startEvent(1)
    end
end

return entity
