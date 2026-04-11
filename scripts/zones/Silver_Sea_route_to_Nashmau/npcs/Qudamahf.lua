-----------------------------------
-- Area: Silver_Sea_route_to_Nashmau
--  NPC: Qudamahf
-- Notes: Tells ship ETA time
-- !pos 0.340 -12.232 -4.120 58
-----------------------------------
---@type TNpcEntity
local entity = {}

local messages =
{
    [xi.transport.message.NEARING] = 'We are nearing Nashmau.',
    [xi.transport.message.DOCKING] = 'We are now docking in Nashmau.',
}

entity.onSpawn = function(npc)
    npc:addPeriodicTrigger(xi.transport.message.NEARING, xi.transport.messageTime.SILVER_SEA, xi.transport.epochOffset.NEARING)
    npc:addPeriodicTrigger(xi.transport.message.DOCKING, xi.transport.messageTime.SILVER_SEA, xi.transport.epochOffset.DOCKING)
end

entity.onTimeTrigger = function(npc, triggerID)
    xi.transport.captainMessage(npc, triggerID, messages)
end

entity.onTrigger = function(player, npc)
    xi.transport.onBoatTimekeeperTrigger(player, npc, xi.transport.routes.SILVER_SEA, 'Nashmau')
end

return entity
