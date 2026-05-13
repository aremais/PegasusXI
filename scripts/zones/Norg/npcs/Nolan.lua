-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Bead Exchange
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
local entity = {}

local function buyEschalixir(player, itemId, cost)
    local beads = player:getCurrency('escha_beads') or 0

    if beads < cost then
        player:printToPlayer(
            string.format('You need %u escha beads for that item.', cost),
            xi.msg.channel.NS_SAY
        )
        return
    end

    if npcUtil.giveItem(player, { { itemId, 1 } }) then
        player:delCurrency('escha_beads', cost)
        player:printToPlayer(
            string.format('You now have %u escha beads.', player:getCurrency('escha_beads')),
            xi.msg.channel.NS_SAY
        )
    end
end

entity.onTrigger = function(player, npc)
    local menu =
    {
        title = 'Nolan: Eschalixir Exchange',

        options =
        {
            {
                'Eschalixir: 10 escha beads',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR, 10)
                end,
            },

            {
                'Eschalixir +1: 50 escha beads',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR_P1, 50)
                end,
            },

            {
                'Eschalixir +2: 2000 escha beads',
                function(playerArg)
                    buyEschalixir(playerArg, xi.item.ESCHALIXIR_P2, 2000)
                end,
            },
        },
    }

    player:customMenu(menu)
end

return entity
