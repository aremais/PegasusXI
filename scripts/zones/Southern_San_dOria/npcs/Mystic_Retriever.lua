-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Mystic Retriever
-----------------------------------
local ID = zones[xi.zone.SOUTHERN_SAN_DORIA]

---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:messageSpecial((ID and ID.text and ID.text.NOTHING_OUT_OF_ORDINARY) or 0)
end

return entity
