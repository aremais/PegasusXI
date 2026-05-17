-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Bead Exchange
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
local entity = {}

local function showPrices(player)
    player:printToPlayer('Eschalixir: 10 Escha Beads', xi.msg.channel.NS_SAY)
    player:printToPlayer('Eschalixir +1: 50 Escha Beads', xi.msg.channel.NS_SAY)
    player:printToPlayer('Eschalixir +2: 2000 Escha Beads', xi.msg.channel.NS_SAY)
end

local function buyEschalixir(player, itemId, cost)
    local beads = player:getCurrency('escha_beads') or 0

    if beads < cost then
        player:printToPlayer(string.format('You need %u Escha Beads.', cost), xi.msg.channel.NS_SAY)
        return
    end

    if npcUtil.giveItem(player, { { itemId, 1 } }) then
        player:delCurrency('escha_beads', cost)
        player:printToPlayer(string.format('Remaining Escha Beads: %u.', player:getCurrency('escha_beads')), xi.msg.channel.NS_SAY)
    end
end

entity.onTrigger = function(player, npc)
    player:printToPlayer('DEBUG: Nolan onTrigger fired.', xi.msg.channel.NS_SAY)

    local menu =
    {
        title = 'Nolan',

        options =
        {
            {
                'Eschalixir',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR, 10)
                end,
            },

            {
                'Eschalixir+1',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR_P1, 50)
                end,
            },

            {
                'Eschalixir+2',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR_P2, 2000)
                end,
            },

            {
                'Prices',
                function(playerArg)
                    showPrices(playerArg)
                end,
            },
        },
    }

    player:customMenu(menu)
end

return entity
