-----------------------------------
-- Area: Norg
--  NPC: Oseem
-- Type: Arcane Glyptics
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        trade:getItemCount() == 1 and
        (
            trade:hasItemQty(xi.item.PELLUCID_STONE, 1) or
            trade:hasItemQty(xi.item.FERN_STONE, 1) or
            trade:hasItemQty(xi.item.TAUPE_STONE, 1)
        )
    then
        player:printToPlayer('Oseem recognizes the stone.', xi.msg.channel.NS_SAY)
        player:printToPlayer('Glyptics are not ready yet.', xi.msg.channel.NS_SAY)
        player:printToPlayer('No items were consumed.', xi.msg.channel.NS_SAY)
    end
end

entity.onTrigger = function(player, npc)
    player:printToPlayer('Glyptics are not ready yet.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Trade a Pellucid, Fern, or Taupe Stone.', xi.msg.channel.NS_SAY)
end

return entity
