-----------------------------------
-- Area: Tavnazian Safehold
--  NPC: Latteaune
-- Type: Melody Minstrel (cutscene replay)
-- !pos -16.426 -27.889 109.626 26
-----------------------------------
require('scripts/globals/melody_minstrel')

---@type TNpcEntity
local entity = {}

local eventId = 100

entity.onTrigger = function(player, npc)
    xi.melodyMinstrel.onTrigger(player, eventId)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.melodyMinstrel.onEventUpdate(player, csid, option, npc, eventId)
end

return entity
