-----------------------------------
-- Area: Norg
--  NPC: Paleille
-- Type: Item Deliverer
-- !pos -82.667 -5.414 52.421 252
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local ID = zones[xi.zone.NORG]

    player:showText(npc, ID.text.PALEILLE_DELIVERY_DIALOG) -- 10371: We can deliver parcels to any residence in Vana'diel.
    player:openSendBox()
end

return entity
