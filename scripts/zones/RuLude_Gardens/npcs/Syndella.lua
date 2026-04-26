-----------------------------------
-- Area: Ru'Lude Gardens
--  NPC: Wrong npc_list `name` (Syndella) for survival guide slot npcid 17772854; same behavior as Survival_Guide.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onSpawn = function(npc)
    npc:renameEntity('Survival Guide', true)
end

entity.onTrigger = function(player, targetNpc)
    xi.survivalGuide.onTrigger(player)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.survivalGuide.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.survivalGuide.onEventFinish(player, csid, option, npc)
end

return entity
