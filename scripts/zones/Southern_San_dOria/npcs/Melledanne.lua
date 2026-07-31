-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Melledanne
-- Type: Melody Minstrel (cutscene replay)
-----------------------------------
require('scripts/globals/melody_minstrel')

---@type TNpcEntity
local entity = {}

local eventId = 943

entity.onTrigger = function(player, npc)
    xi.melodyMinstrel.onTrigger(player, eventId)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.melodyMinstrel.onEventUpdate(player, csid, option, npc, eventId)
end

return entity
