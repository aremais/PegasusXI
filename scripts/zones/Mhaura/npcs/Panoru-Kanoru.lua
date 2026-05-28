-----------------------------------
-- Area: Mhaura
--  NPC: Panoru-Kanoru
-- Type: Item Deliverer
-- !pos 5.241    -4.035    93.891 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:showText(npc, 7784)
    player:openSendBox()
end

return entity
