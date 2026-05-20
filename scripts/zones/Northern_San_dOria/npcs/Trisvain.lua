-----------------------------------
-- Area: Northern San d'Oria
--  NPC: Trisvain
-- Type: High-Tier Mission Battlefield Phantom Gem Vendor
-- !pos 28.317 -0.199 84.776 103
--
-- Sells Phantom Gems for merit points, granting access to
-- High-Tier Mission Battlefields.
-- Requires main job level 95 or higher.
-----------------------------------
require('scripts/globals/htbf')

---@type TNpcEntity
local entity = {}

local menuTitle = 'Phantom Gem Registration'
local lowLvlMsg =
    'Only veterans proven in battle may enter the High-Tier Mission Battlefields. ' ..
    'Return when your main job has reached level 95, and I shall assist you.'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
