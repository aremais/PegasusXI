-----------------------------------
-- Area: Windurst Woods
--  NPC: Repairer Moogle
-- !pos 98.030 -5.220 -21.780 241
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onSpawn = function(npc)
    npc:renameEntity('Repairer Moogle', true)
end

entity.onTrade = function(player, npc, trade)
    xi.repairerMoogle.onTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    xi.repairerMoogle.onTrigger(player, npc)
end

return entity
