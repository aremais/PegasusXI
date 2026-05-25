-----------------------------------
-- Area: Port Bastok
--  NPC: Raving Opossum
-- Type: High-Tier Mission Battlefield Phantom Gem Vendor
-- !pos 42.141 7.500 -183.762 107
--
-- Sells Phantom Gems for merit points, granting access to
-- High-Tier Mission Battlefields.
-- Requires main job level 95 or higher.
-----------------------------------
require('scripts/globals/htbf')

---@type TNpcEntity
local entity = {}

local menuTitle = 'Phantom Gem Exchange'
local lowLvlMsg =
    'Whoooa, hold it right there, friend! ' ..
    'These battlefields are no joke -- you\'ve gotta be at LEAST level 95 to even ' ..
    'think about stepping foot in one! Come back when you\'re tougher, yeah?'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
