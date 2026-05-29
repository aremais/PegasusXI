-----------------------------------
-- Area: Ordelles Caves
--  NPC: Ruillont
-- Involved in Mission: The Rescue Drill
-- !pos -70 1 607 193
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local ID = zones[xi.zone.ORDELLES_CAVES]

    -- Ruillont Default Actions vary based on Nation
    if player:getNation() == xi.nation.SANDORIA then
        player:showText(npc, ID.text.RUILLONT_SANDORIA_DIALOG, 0, 0, 0, 0, true, false) -- 7366
    else
        player:showText(npc, ID.text.RUILLONT_DEFAULT_DIALOG, 0, 0, 0, 0, true, false) -- 7370
    end
end

return entity
