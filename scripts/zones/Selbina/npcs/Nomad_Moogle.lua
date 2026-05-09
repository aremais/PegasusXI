-----------------------------------
-- Area: Selbina
--  NPC: Nomad Moogle
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local ID = zones[xi.zone.SELBINA]

    player:showText(npc, ID.text.NOMAD_MOOGLE_DIALOG)
    player:sendMenu(xi.menuType.MOOGLE)
end

return entity
