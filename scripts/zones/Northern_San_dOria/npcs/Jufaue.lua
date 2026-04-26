-----------------------------------
-- Area: Northern San d'Oria
--  NPC: Jufaue
-- Type: Melody Minstrel (cutscene replay)
-----------------------------------
require('scripts/globals/melody_minstrel')

---@type TNpcEntity
local entity = {}

local eventId = 715

entity.onTrigger = function(player, npc)
    xi.melodyMinstrel.onTrigger(player, eventId)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.melodyMinstrel.onEventUpdate(player, csid, option, npc, eventId)
end

return entity
