-----------------------------------
-- Area: Open_sea_route_to_Al_Zahbi
--  NPC: Adeben
-- Notes: Tells ship ETA time
-- !pos 0.340 -12.232 -4.120 46
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.OPEN_SEA, 'Al Zahbi')
end

return entity
