-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Mezzotinting
-----------------------------------
---@type TNpcEntity
local entity = {}

local eschalixirExchange =
{
    {
        label = 'Eschalixir - 10 beads',
        item  = xi.item.ESCHALIXIR,
        cost  = 10,
    },
    {
        label = 'Eschalixir +1 - 50 beads',
        item  = xi.item.ESCHALIXIR_P1,
        cost  = 50,
    },
    {
        label = 'Eschalixir +2 - 2000 beads',
        item  = xi.item.ESCHALIXIR_P2,
        cost  = 2000,
    },
}

local function buyEschalixir(player, exchange)
    local beads = player:getCurrency('escha_beads') or 0

    if beads < exchange.cost then
        player:printToPlayer('You do not have enough escha beads.', xi.msg.channel.NS_SAY)
        return
    end

    if npcUtil.giveItem(player, { { exchange.item, 1 } }) then
        player:delCurrency('escha_beads', exchange.cost)
        player:printToPlayer(string.format('Nolan accepts %u escha beads.', exchange.cost), xi.msg.channel.NS_SAY)
    end
end

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
    local menu =
    {
        title = 'Nolan: Escha Bead Exchange',
        options = {},
    }

    for _, exchange in ipairs(eschalixirExchange) do
        table.insert(menu.options, {
            exchange.label,
            function(p)
                buyEschalixir(p, exchange)
            end,
        })
    end

    table.insert(menu.options, {
        'About mezzotinting',
        function(p)
            p:printToPlayer('Trade an Eschalixir to continue.', xi.msg.channel.NS_SAY)
            p:printToPlayer('Mezzotinting is not ready yet.', xi.msg.channel.NS_SAY)
        end,
    })

    table.insert(menu.options, {
        'Cancel',
        function(_)
        end,
    })

    player:customMenu(menu)
end

return entity
