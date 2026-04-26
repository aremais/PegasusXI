-----------------------------------
-- Area: Ru'Lude Gardens
--  NPC: Survival Guide
-----------------------------------
---@type TNpcEntity
local entity = {}

-- Correct bad npc_list rows that send the wrong polutils_name (e.g. "Syndella") to the client.
entity.onSpawn = function(npc)
    if npc:getPacketName() ~= 'Survival Guide' then
        npc:renameEntity('Survival Guide', true)
    end
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
