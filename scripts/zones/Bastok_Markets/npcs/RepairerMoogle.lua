-----------------------------------
-- Area: Bastok Markets
--  NPC: Repairer Moogle
-- !pos -338.470 -10.000 -183.940 235
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
