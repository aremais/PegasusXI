-----------------------------------
-- Nolan Event Range Probe
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.nolanShop = xi.nolanShop or {}

local eventIds =
{
    9500,
    9501,
    9502,
    9503,
    9504,
    9505,
    9506,
    9507,
    9508,
    9509,
    9510,
    9511,
    9513,
    9514,
    9515,
    9516,
    9517,
    9518,
    9519,
    9520,
    9521,
    9522,
    9523,
    9524,
    9525,
}

local eschalixirItems =
{
    [1] =
    {
        [1] =
        {
            [1] = { item = xi.item.ESCHALIXIR,    cost = 10 },
            [2] = { item = xi.item.ESCHALIXIR_P1, cost = 50 },
            [3] = { item = xi.item.ESCHALIXIR_P2, cost = 2000 },
        },
    },
}

local function buyFromOption(player, option)
    local itemPage     = bit.band(bit.rshift(option, 2), 0x0F) + 1
    local itemSelected = bit.band(bit.rshift(option, 6), 0x0F) + 1
    local itemSubPage  = bit.band(bit.rshift(option, 10), 0x0F) + 1

    local beads = player:getCurrency('escha_beads') or 0

    local purchase =
        eschalixirItems[itemPage] and
        eschalixirItems[itemPage][itemSubPage] and
        eschalixirItems[itemPage][itemSubPage][itemSelected]

    if purchase ~= nil then
        if beads < purchase.cost then
            player:printToPlayer(string.format('You need %u Escha Beads.', purchase.cost), xi.msg.channel.NS_SAY)
        elseif npcUtil.giveItem(player, { { purchase.item, 1 } }) then
            player:delCurrency('escha_beads', purchase.cost)
            beads = beads - purchase.cost
            player:printToPlayer(string.format('Nolan accepts %u Escha Beads.', purchase.cost), xi.msg.channel.NS_SAY)
        end
    end

    return beads
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
    local index = player:getCharVar('NolanEventProbeIndex') + 1

    if index > #eventIds then
        index = 1
    end

    player:setCharVar('NolanEventProbeIndex', index)

    local eventId = eventIds[index]
    local beads = player:getCurrency('escha_beads') or 0

    player:printToPlayer(string.format('Nolan event probe: testing Norg event %u (%u/%u).', eventId, index, #eventIds), xi.msg.channel.NS_SAY)
    player:startEvent(eventId, beads)
end

xi.nolanShop.onEventUpdate = function(player, csid, option, npc)
    local beads = buyFromOption(player, option)

    player:printToPlayer(string.format('Nolan probe update: csid=%u option=%u.', csid, option), xi.msg.channel.NS_SAY)
    player:updateEvent(beads)
end

xi.nolanShop.onEventFinish = function(player, csid, option, npc)
    player:printToPlayer(string.format('Nolan probe finish: csid=%u option=%u.', csid, option), xi.msg.channel.NS_SAY)
end
