-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Repairer Moogle
-- !pos -86.850 1.000 -54.250 230
-----------------------------------
---@type TNpcEntity
local entity = {}

-- Client slot 738 otherwise shows generic "NPC" despite polutils_name in npc_list.
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
