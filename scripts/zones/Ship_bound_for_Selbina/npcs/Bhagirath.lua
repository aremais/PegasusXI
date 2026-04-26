-----------------------------------
-- Area: Ship_bound_for_Selbina
--  NPC: Bhagirath
-- Notes: Tells ship ETA time
-- !pos 0.278 -14.707 -1.411 220
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.SELBINA_MHAURA, 'Selbina')
end

return entity
