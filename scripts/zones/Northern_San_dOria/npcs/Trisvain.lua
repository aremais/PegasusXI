-----------------------------------
-- Area: Northern San d'Oria
-- NPC: Trisvain (Phantom Gem Registration)
-- Custom: HTBF phantom gem vendor
-----------------------------------
require('scripts/globals/htbf')
-----------------------------------

local entity = {}

local menuTitle = 'Phantom Gem Registration'
local lowLvlMsg =
    'Only veterans proven in battle may enter the High-Tier Mission ' ..
    'Battlefields. Return when your main job has reached level 95, and ' ..
    'I shall assist you.'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
