-----------------------------------
-- Zone: RuLude_Gardens (243)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    zone:registerCuboidTriggerArea(1, -16, 0, 32, 16, 4, 86) -- Palace entrance. Ends at back exit. Needs retail confirmaton for the back entrance.

    -- Ru'Lude survival guide (I-10): runs after NPCs are spawned. Fixes bad npc_list rows where
    -- polutils_name is still "Syndella" (Survival_Guide.lua never loads if internal name is Syndella).
    local guide = GetNPCByID(17772854)
    if guide and guide:getPacketName() ~= 'Survival Guide' then
        guide:renameEntity('Survival Guide', true)
    end
end

zoneObject.onZoneIn = function(player, prevZone)
    return xi.moghouse.onMoghouseZoneEvent(player, prevZone)
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onTriggerAreaLeave = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
