-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Mezzotinting
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        trade:getItemCount() == 1 and
        (
            trade:hasItemQty(xi.item.ESCHALIXIR, 1) or
            trade:hasItemQty(xi.item.ESCHALIXIR_P1, 1) or
            trade:hasItemQty(xi.item.ESCHALIXIR_P2, 1)
        )
    then
        player:printToPlayer('Nolan recognizes the Eschalixir.', xi.msg.channel.NS_SAY)
        player:printToPlayer('Mezzotinting is not ready yet.', xi.msg.channel.NS_SAY)
        player:printToPlayer('No items were consumed.', xi.msg.channel.NS_SAY)
    end
end

entity.onTrigger = function(player, npc)
    player:printToPlayer('Nolan handles Escha mezzotinting.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Trade an Eschalixir to continue.', xi.msg.channel.NS_SAY)
end

return entity
