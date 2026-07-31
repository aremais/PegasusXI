-----------------------------------
-- Area: Ship_bound_for_Mhaura
--  NPC: Sahn
-- Notes: Tells ship ETA time
-- !pos 0.278 -14.707 -1.411 221
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.SELBINA_MHAURA, 'Mhaura')
end

return entity
