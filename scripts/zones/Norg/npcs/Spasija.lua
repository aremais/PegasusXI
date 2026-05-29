-----------------------------------
-- Area: Norg
--  NPC: Spasija
-- Type: Item Deliverer
-- !pos -82.896 -5.414 55.271 252
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local ID = zones[xi.zone.NORG]

    player:showText(npc, ID.text.SPASIJA_DELIVERY_DIALOG) -- 10370: Hiya! I can deliver packages to anybody, anywhere, anytime. What do you say?
    player:openSendBox()
end

return entity
