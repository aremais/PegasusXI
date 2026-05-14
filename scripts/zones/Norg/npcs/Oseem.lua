-----------------------------------
-- Area: Norg
--  NPC: Oseem
-- Type: Arcane Glyptics
-----------------------------------
local entity = {}

entity.onTrigger = function(player, npc)
    local menu =
    {
        title = 'Oseem: Arcane Glyptics',

        options =
        {
            {
                'Ask about arcane glyptics',
                function(playerArg)
                    playerArg:printToPlayer('Oseem can inscribe equipment with arcane glyptics using Pellucid, Fern, and Taupe Stones.', xi.msg.channel.NS_SAY)
                    playerArg:printToPlayer('Arcane glyptics augmentation is not implemented yet.', xi.msg.channel.NS_SAY)
                end,
            },

            {
                'Ask about stones',
                function(playerArg)
                    playerArg:printToPlayer('Pellucid Stones, Fern Stones, and Taupe Stones can be obtained from Reisenjima enemies.', xi.msg.channel.NS_SAY)
                end,
            },
        },
    }

    player:customMenu(menu)
end

return entity
