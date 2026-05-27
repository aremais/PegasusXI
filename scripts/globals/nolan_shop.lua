-----------------------------------
-- Nolan Escha Bead Exchange
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.nolanShop = xi.nolanShop or {}

local eschalixirExchange =
{
    {
        label = 'Eschalixir',
        item  = xi.item.ESCHALIXIR,
        cost  = 10,
    },
    {
        label = '+1',
        item  = xi.item.ESCHALIXIR_P1,
        cost  = 50,
    },
    {
        label = '+2',
        item  = xi.item.ESCHALIXIR_P2,
        cost  = 2000,
    },
}

local function showPrices(player)
    player:printToPlayer('Eschalixir: 10 beads.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Eschalixir +1: 50 beads.', xi.msg.channel.NS_SAY)
    player:printToPlayer('Eschalixir +2: 2000 beads.', xi.msg.channel.NS_SAY)
end

local function buyEschalixir(player, exchange)
    local beads = player:getCurrency('escha_beads') or 0

    if beads < exchange.cost then
        player:printToPlayer(string.format('You need %u Escha Beads.', exchange.cost), xi.msg.channel.NS_SAY)
        return
    end

    if npcUtil.giveItem(player, { { exchange.item, 1 } }) then
        player:delCurrency('escha_beads', exchange.cost)
        player:printToPlayer(string.format('Nolan accepts %u Escha Beads.', exchange.cost), xi.msg.channel.NS_SAY)
    end
end

local function openEschalixirMenu(player)
    local menu =
    {
        title = 'Eschalixirs',
        options = {},
    }

    for _, entry in ipairs(eschalixirExchange) do
        local exchange = entry

        table.insert(menu.options, {
            exchange.label,
            function(p)
                buyEschalixir(p, exchange)
            end,
        })
    end

    table.insert(menu.options, {
        'Prices',
        function(p)
            showPrices(p)
        end,
    })

    table.insert(menu.options, {
        'Back',
        function(p)
            xi.nolanShop.onTrigger(p)
        end,
    })

    player:customMenu(menu)
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
        title = 'Nolan',
        options =
        {
            {
                'Mezzotinting',
                function(p)
                    p:printToPlayer('Trade eligible Escha equipment to begin.', xi.msg.channel.NS_SAY)
                    p:printToPlayer('Mezzotinting is not ready yet.', xi.msg.channel.NS_SAY)
                end,
            },

            {
                'Eschalixirs',
                function(p)
                    openEschalixirMenu(p)
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

xi.nolanShop.onEventUpdate = function(player, csid, option, npc)
end

xi.nolanShop.onEventFinish = function(player, csid, option, npc)
end
