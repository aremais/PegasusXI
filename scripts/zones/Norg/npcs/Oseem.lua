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
        player:printToPlayer('Oseem recognizes the arcane glyptics stone.', xi.msg.channel.NS_SAY)
        player:printToPlayer('Arcane glyptics augmentation is not implemented yet.', xi.msg.channel.NS_SAY)
        player:printToPlayer('No items were consumed.', xi.msg.channel.NS_SAY)
    end
end

entity.onTrigger = function(player, npc)
    player:printToPlayer('Arcane glyptics are not implemented yet.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Trade Pellucid, Fern, or Taupe Stones for a placeholder response.', xi.msg.channel.NS_SAY)
end

return entity
