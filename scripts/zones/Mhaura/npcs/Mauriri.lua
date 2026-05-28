-----------------------------------
-- Area: Mhaura
--  NPC: Mauriri
-- Type: Item Deliverer
-- !pos 10.883    -15.99    66.186 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:showText(npc, 7783)
    player:openSendBox()
end

return entity
