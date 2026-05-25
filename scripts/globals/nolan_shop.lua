-----------------------------------
-- Nolan Escha Bead Exchange
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.nolanShop = xi.nolanShop or {}

local function buyEschalixir(player, itemId, cost)
    local beads = player:getCurrency('escha_beads') or 0

    if beads < cost then
        player:printToPlayer(string.format('You need %u Escha Beads.', cost), xi.msg.channel.NS_SAY)
        return
    end

    if npcUtil.giveItem(player, { { itemId, 1 } }) then
        player:delCurrency('escha_beads', cost)
        player:printToPlayer(string.format('Nolan accepts %u Escha Beads.', cost), xi.msg.channel.NS_SAY)
    end
end

xi.nolanShop.onTrade = function(player, npc, trade)
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

xi.nolanShop.onTrigger = function(player, npc)
    player:printToPlayer('Another customer. Joy.', xi.msg.channel.NS_SAY)

    player:customMenu({
        title = 'Buy Eschalixirs',
        options =
        {
            {
                'Eschalixir',
                function(p)
                    buyEschalixir(p, xi.item.ESCHALIXIR, 10)
                end,
            },
            {
                '+1',
                function(p)
                    buyEschalixir(p, xi.item.ESCHALIXIR_P1, 50)
                end,
            },
            {
                '+2',
                function(p)
                    buyEschalixir(p, xi.item.ESCHALIXIR_P2, 2000)
                end,
            },
            {
                'Cancel',
                function(_)
                end,
            },
        },
    })
end
