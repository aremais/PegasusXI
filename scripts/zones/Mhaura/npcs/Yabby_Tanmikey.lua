-----------------------------------
-- Area: Mhaura
--  NPC: Yabby Tanmikey
--  Guild Merchant NPC: Goldsmithing Guild
-- !pos -36.459 -16.000 76.840 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:sendGuild(528, 8, 23, 4) then
        player:showText(npc, 7185)
    end
end

return entity
