-----------------------------------
-- Area: Nashmau
--  NPC: Nomad Moogle
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:showText(npc, 7347)
    player:sendMenu(xi.menuType.MOOGLE)
end

return entity
