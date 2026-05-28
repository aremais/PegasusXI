-----------------------------------
-- Area: Nashmau
--  NPC: Neneroon
-- Type: Item Deliverer
-- !pos -0.866    -5.999    36.942 53
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:showText(npc, 10862)
    player:openSendBox()
end

return entity
