-----------------------------------
-- Area: Port Bastok
-- NPC: Raving Opossum (Phantom Gem Exchange)
-- Custom: HTBF phantom gem vendor
-----------------------------------
require('scripts/globals/htbf')
-----------------------------------

local entity = {}

local menuTitle = 'Phantom Gem Exchange'
local lowLvlMsg =
    'Whoooa, hold it right there, friend! These battlefields are no joke ' ..
    '-- you\'ve gotta be at LEAST level 95 to even think about stepping ' ..
    'foot in one! Come back when you\'re tougher, yeah?'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
