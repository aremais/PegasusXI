-----------------------------------
-- Area: Chateau d'Oraguille
--  NPC: Chaloutte
-- Type: Melody Minstrel (cutscene replay)
-----------------------------------
require('scripts/globals/melody_minstrel')

---@type TNpcEntity
local entity = {}

local eventId = 557

entity.onTrigger = function(player, npc)
    xi.melodyMinstrel.onTrigger(player, eventId)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.melodyMinstrel.onEventUpdate(player, csid, option, npc, eventId)
end

return entity
