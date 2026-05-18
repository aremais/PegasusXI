-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Bead Exchange
-----------------------------------
local entity = {}

entity.onTrigger = function(player, npc)
    player:printToPlayer('Nolan exchanges Escha Beads for Eschalixirs.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Eschalixir: 10 beads. Eschalixir +1: 50 beads. Eschalixir +2: 2000 beads.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Direct purchase is not implemented yet.', xi.msg.channel.NS_SAY)
end

return entity
