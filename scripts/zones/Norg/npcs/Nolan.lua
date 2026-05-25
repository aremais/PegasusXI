-----------------------------------
-- Area: Norg
--  NPC: Nolan
-- Type: Escha Bead Exchange
-----------------------------------
require('scripts/globals/nolan_shop')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.nolanShop.onTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    xi.nolanShop.onTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.nolanShop.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.nolanShop.onEventFinish(player, csid, option, npc)
end

return entity
