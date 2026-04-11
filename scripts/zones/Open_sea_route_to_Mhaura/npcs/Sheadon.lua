-----------------------------------
-- Area: Open_sea_route_to_Mhaura
--  NPC: Sheadon
-- Notes: Tells ship ETA time
-- !pos 0.340 -12.232 -4.120 47
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.OPEN_SEA, 'Mhaura')
end

return entity
