-----------------------------------
-- Area: Ship bound for Mhaura Pirates
--  NPC: Sahn
-- Notes: Tells ship ETA time
-- !pos 0.28 -14.0 -1.411 221
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.SELBINA_MHAURA, 'Mhaura')
end

return entity
