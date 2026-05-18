-----------------------------------
-- Area: Port Windurst
-- NPC: Mimble-Pimble (Phantom Gem Registration)
-- Custom: HTBF phantom gem vendor
-----------------------------------
require('scripts/globals/htbf')
-----------------------------------

local entity = {}

local menuTitle = 'Phantom Gem Registration'
local lowLvlMsg =
    'Oh my oh my, you are far too small-and-all to be entering a battlefield ' ..
    'of this caliber! Come back when your main job has reachedy-reached level ' ..
    'ninety-five, yes yes!'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
