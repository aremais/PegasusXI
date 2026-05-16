-----------------------------------
-- Area: Port Windurst
--  NPC: Mimble-Pimble
-- Type: High-Tier Mission Battlefield Phantom Gem Vendor
-- !pos 197.507 -8.670 177.602 110
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
    'Oh my oh my, you are far too small-and-all to be entering a battlefield ' ..
    'of this caliber! Come back when your main job has reachedy-reached level ' ..
    'ninety-five, yes yes!'

entity.onTrigger = function(player, npc)
    xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
end

return entity
