-----------------------------------
-- Area: Nashmau
--  NPC: Nanaroon
-- Type: Item Deliverer
-- !pos -2.404    -6    37.141 53
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:showText(npc, 10863)
    player:openSendBox()
end

return entity
