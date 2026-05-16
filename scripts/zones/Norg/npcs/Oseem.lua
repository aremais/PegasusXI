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
    local menu =
    {
        title = 'Oseem',

        options =
        {
            {
                'Glyptics',
                function(playerArg)
                    playerArg:printToPlayer('Oseem can inscribe equipment with arcane glyptics using Pellucid, Fern, and Taupe Stones.', xi.msg.channel.NS_SAY)
                    playerArg:printToPlayer('Arcane glyptics augmentation is not implemented yet.', xi.msg.channel.NS_SAY)
                end,
            },

            {
                'Stones',
                function(playerArg)
                    playerArg:printToPlayer('Pellucid Stones, Fern Stones, and Taupe Stones can be obtained from Reisenjima enemies.', xi.msg.channel.NS_SAY)
                end,
            },
        },
    }

    player:customMenu(menu)
end

return entity
