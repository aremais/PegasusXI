-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Event Probe
-----------------------------------
---@type TNpcEntity
local entity = {}

local probeEvent = 9512

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:printToPlayer(string.format('Testing Nolan event %u.', probeEvent), xi.msg.channel.SYSTEM_3)
    player:startEvent(probeEvent, player:getCurrency('escha_beads'), player:getCurrency('escha_silt'))
end

entity.onEventUpdate = function(player, csid, option, npc)
    player:printToPlayer(string.format('Nolan event update: csid=%u option=%u.', csid, option), xi.msg.channel.SYSTEM_3)
    player:updateEvent(player:getCurrency('escha_beads'), player:getCurrency('escha_silt'))
end

entity.onEventFinish = function(player, csid, option, npc)
    player:printToPlayer(string.format('Nolan event finish: csid=%u option=%u.', csid, option), xi.msg.channel.SYSTEM_3)
end

return entity
